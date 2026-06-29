import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:torch_light/torch_light.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:my_app/modules/hospital_map_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'result_screen.dart';

/// Background-isolate preprocessing (compute() ke liye top-level hona zaroori).
/// Full-res decode + resize + normalize yahin worker isolate mein hota hai;
/// isolate band hote hi saari intermediate memory (poora bitmap) turant
/// reclaim ho jati hai -> main isolate par peak RAM spike kam.
Float32List _preprocessSkinImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception("Decode Error");
  final resized = img.copyResize(decoded, width: 299, height: 299);

  final input = Float32List(299 * 299 * 3);
  var i = 0;
  for (var y = 0; y < 299; y++) {
    for (var x = 0; x < 299; x++) {
      final pixel = resized.getPixel(x, y);
      input[i++] = (pixel.r.toDouble() - 127.5) / 127.5;
      input[i++] = (pixel.g.toDouble() - 127.5) / 127.5;
      input[i++] = (pixel.b.toDouble() - 127.5) / 127.5;
    }
  }
  return input;
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isFlashOn = false;

  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  List<String>? _labels;
  String _result = "AI SYSTEM ONLINE";
  bool _isModelLoaded = false;
  bool _isAnalyzing = false;
  Color _statusColor = Colors.cyanAccent;
  double _confidence = 0.0;

  final Map<String, List<String>> _precautions = {
    "MELANOMA": [
      "Avoid direct sunlight, especially between 10 AM - 4 PM.",
      "Apply broad-spectrum sunscreen (SPF 30 or higher).",
      "Do not scratch or irritate the affected area.",
      "Consult a dermatologist immediately for a biopsy.",
      "Monitor other moles for changes in shape or color."
    ],
    "BASAL CELL CARCINOMA": [
      "Keep the area clean and covered.",
      "Protect your skin from UV radiation.",
      "Monitor for any changes in size or color.",
      "Schedule a professional skin examination.",
      "Avoid tanning beds and prolonged sun exposure."
    ],
    "ATOPIC DERMATITIS": [
      "Use fragrance-free moisturizers regularly.",
      "Avoid harsh soaps and detergents.",
      "Take short, lukewarm showers instead of hot ones.",
      "Identify and avoid personal allergy triggers.",
      "Wear soft, breathable cotton clothing."
    ],
    "FUNGAL INFECTION": [
      "Keep the affected area dry and clean.",
      "Do not share personal items like towels or socks.",
      "Use prescribed anti-fungal ointments regularly.",
      "Avoid tight-fitting clothes that trap sweat.",
      "Wash hands thoroughly after touching the area."
    ],
    "NORMAL": [
      "Continue maintaining good skin hygiene.",
      "Stay hydrated and eat antioxidant-rich foods.",
      "Use daily moisturizer and sunscreen.",
      "Perform a self-check once a month.",
      "Protect skin from extreme pollution."
    ],
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () => _initModel());
  }

  Future<void> _initModel() async {
    if (_isModelLoaded && _interpreter != null) return;
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
          'assets/SkinSentinel_PRO_V3.tflite',
          options: options);

      // Inference ko background isolate par chalane ke liye. Yeh ek hi loaded
      // model (native pointer 'address') reuse karta hai -> RAM double NAHI hoti.
      _isolateInterpreter =
          await IsolateInterpreter.create(address: _interpreter!.address);

      if (_labels == null) {
        final labelData = await rootBundle.loadString('assets/labels.txt');
        _labels = labelData
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      if (mounted) setState(() => _isModelLoaded = true);
    } catch (e) {
      debugPrint("❌ Model Error: $e");
    }
  }

  Future<void> _classifyImage(File image) async {
    if (!_isModelLoaded) await _initModel();
    if (_interpreter == null) return;

    setState(() {
      _isAnalyzing = true;
      _result = "EXTRACTING DERMAL PATTERNS...";
    });

    try {
      final labels = _labels ?? const <String>[];
      if (labels.isEmpty) throw Exception("Labels not loaded");

      // 1) Sirf bytes read karein, phir heavy decode/resize/normalize ko
      //    background isolate par bhej dein. compute() ka worker isolate apna
      //    poora heap (full-res bitmap samet) return hote hi free kar deta hai,
      //    isliye main isolate par peak RAM spike bahut kam ho jata hai.
      final bytes = await image.readAsBytes();
      final Float32List input = await compute(_preprocessSkinImage, bytes);

      // 2) Inference bhi background isolate par chalayein taake bhaari native
      //    run() UI thread ko block na kare (jo ANR/skip-frames -> OS kill banta).
      final output =
          List<double>.filled(labels.length, 0).reshape([1, labels.length]);
      await _isolateInterpreter!.run(input.reshape([1, 299, 299, 3]), output);

      // Safe conversion: output[0] dynamic hai; har score ko num? se double banate hain
      final rawScores = (output[0] as List?) ?? const [];
      List<double> scores =
          rawScores.map((e) => (e as num?)?.toDouble() ?? 0.0).toList();
      if (scores.isEmpty) throw Exception("Empty inference output");

      double maxScore = scores.reduce((a, b) => a > b ? a : b);
      int maxIdx = scores.indexOf(maxScore);
      double totalScore = scores.fold(0, (p, c) => p + c);
      // Divide-by-zero se bachao
      double finalConfidence =
          totalScore > 0 ? (maxScore / totalScore) * 100 : 0.0;

      // Label missing/out-of-range ho toh "UNKNOWN" par fallback (crash nahi)
      final String safeLabel =
          (maxIdx >= 0 && maxIdx < labels.length) ? labels[maxIdx] : "UNKNOWN";
      String rawLabel =
          (safeLabel.toString()).toUpperCase().replaceAll('_', ' ').trim();
      if (rawLabel.isEmpty) rawLabel = "UNKNOWN";

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _confidence = double.parse(finalConfidence.toStringAsFixed(1));

          bool isDangerous =
              rawLabel.contains("MELANOMA") || rawLabel.contains("CARCINOMA");

          if (isDangerous) {
            _statusColor =
                finalConfidence > 75.0 ? Colors.redAccent : Colors.orangeAccent;
          } else {
            _statusColor =
                finalConfidence > 65.0 ? Colors.greenAccent : Colors.cyanAccent;
          }
          _result = "$rawLabel DETECTED";
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              scanData: {
                'label': rawLabel,
                'accuracy': _confidence,
                'imageUrl': image.path,
                'isFromHistory': false,
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isAnalyzing = false);
      debugPrint("Classification Error: $e");
    }
  }

  void _shareResult() {
    if (_result.contains("ONLINE") || _isAnalyzing) return;
    String res = _result.split('\n')[0].toUpperCase().trim();
    String diseaseKey = "NORMAL";
    if (res.contains("MELANOMA"))
      diseaseKey = "MELANOMA";
    else if (res.contains("CARCINOMA"))
      diseaseKey = "BASAL CELL CARCINOMA";
    else if (res.contains("DERMATITIS")) diseaseKey = "ATOPIC DERMATITIS";

    List<String> tips = _precautions[diseaseKey] ?? ["Consult a specialist."];
    String shareText =
        "🚀 SKINSENTINEL REPORT\nResult: $res\nAccuracy: ${_confidence}%\n\nPrecautions:\n${tips.join('\n')}";
    Share.share(shareText);
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _statusColor = Colors.cyanAccent;
      });
      await _classifyImage(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check theme mode
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF040508) : Colors.grey[50],
      body: Stack(
        children: [
          _buildBackgroundOrb(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 10),
                _buildDisplayArea(isDark),
                const SizedBox(height: 10),
                if (_image != null &&
                    !_isAnalyzing &&
                    _confidence >= 40.0 &&
                    !_result.contains("NORMAL"))
                  _buildSpecialistButton(),
                if (_image != null && !_isAnalyzing) _buildShareButton(),
                const SizedBox(height: 10),
                Expanded(child: Center(child: _buildScannerFrame(isDark))),
                const SizedBox(height: 20),
                _buildBottomControls(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text("PRO AI SCANNER",
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const Text("InceptionResNet V3 Engine",
                  style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.1),
                shape: BoxShape.circle),
            child:
                const Icon(Icons.security, color: Colors.cyanAccent, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayArea(bool isDark) {
    String res = _result.split('\n')[0].toUpperCase().trim();
    String diseaseKey = "NORMAL";
    if (res.contains("MELANOMA"))
      diseaseKey = "MELANOMA";
    else if (res.contains("CARCINOMA"))
      diseaseKey = "BASAL CELL CARCINOMA";
    else if (res.contains("DERMATITIS"))
      diseaseKey = "ATOPIC DERMATITIS";
    else if (res.contains("FUNGAL")) diseaseKey = "FUNGAL INFECTION";

    List<String> tips = _precautions[diseaseKey] ?? ["Consult a specialist."];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: _statusColor.withOpacity(0.02),
              blurRadius: 20,
              spreadRadius: 5)
        ],
      ),
      child: Column(
        children: [
          Text(_result,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _statusColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.4)),
          if (_image != null && !_isAnalyzing) ...[
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                  value: _confidence / 100,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  color: _statusColor,
                  minHeight: 6),
            ),
            const Divider(color: Colors.white10, height: 35),
            ...tips
                .map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: _statusColor, size: 14),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(tip,
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: 11,
                                      height: 1.3))),
                        ],
                      ),
                    ))
                .toList(),
          ]
        ],
      ),
    );
  }

  Widget _buildScannerFrame(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 310,
          height: 310,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  width: 1)),
        ),
        Container(
          width: 285,
          height: 285,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.cover)
                : Icon(Icons.center_focus_weak_rounded,
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    size: 100),
          ),
        ),
        if (_isAnalyzing) _buildScanLine(),
        _buildCorners(),
      ],
    );
  }

  Widget _buildScanLine() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: 60 + (_controller.value * 165),
          child: Container(
            width: 250,
            height: 3,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 15)
              ],
              gradient: const LinearGradient(colors: [
                Colors.transparent,
                Colors.cyanAccent,
                Colors.transparent
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
        boxShadow:
            isDark ? [] : [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.photo_library_outlined, "GALLERY",
              () => _pickImage(ImageSource.gallery), isDark),
          _buildMainPulseButton(),
          _buildActionButton(
              _isFlashOn ? Icons.flash_on : Icons.flash_off, "FLASH", () async {
            try {
              if (_isFlashOn)
                await TorchLight.disableTorch();
              else
                await TorchLight.enableTorch();
              setState(() => _isFlashOn = !_isFlashOn);
            } catch (e) {
              debugPrint("Flash error");
            }
          }, isDark),
        ],
      ),
    );
  }

  Widget _buildMainPulseButton() {
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.camera),
      child: Container(
        height: 85,
        width: 85,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
              colors: [Colors.cyanAccent, Colors.blueAccent]),
          boxShadow: [
            BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 20)
          ],
        ),
        child:
            const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 38),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 28),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSpecialistButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _statusColor.withOpacity(0.15),
          side: BorderSide(color: _statusColor),
          minimumSize: const Size(double.infinity, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (c) => const HospitalMapScreen())),
        icon: Icon(Icons.location_on_rounded, color: _statusColor, size: 18),
        label: Text("FIND NEARBY CLINICS",
            style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildShareButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _statusColor.withOpacity(0.5)),
          minimumSize: const Size(double.infinity, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: _shareResult,
        icon: Icon(Icons.share_rounded, color: _statusColor, size: 18),
        label: Text("SHARE ANALYSIS",
            style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBackgroundOrb() {
    return Positioned(
      top: -100,
      right: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.08)),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container()),
      ),
    );
  }

  Widget _buildCorners() {
    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(painter: ScannerCornersPainter(color: _statusColor)),
    );
  }

  @override
  void dispose() {
    _isolateInterpreter?.close();
    _interpreter?.close();
    _controller.dispose();
    super.dispose();
  }
}

class ScannerCornersPainter extends CustomPainter {
  final Color color;
  ScannerCornersPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const double len = 25;
    canvas.drawPath(
        Path()
          ..moveTo(0, len)
          ..lineTo(0, 0)
          ..lineTo(len, 0),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(size.width - len, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width, len),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(0, size.height - len)
          ..lineTo(0, size.height)
          ..lineTo(len, size.height),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(size.width - len, size.height)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width, size.height - len),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
