import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

// Note: Ensure hospital_map_screen.dart and other imports exist in your project
// import 'package:my_app/modules/hospital_map_screen.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic>? scanData;
  const ResultScreen({super.key, this.scanData});

  @override
  Widget build(BuildContext context) {
    return ResultView(scanData: scanData);
  }
}

class ResultView extends StatefulWidget {
  final Map<String, dynamic>? scanData;
  const ResultView({super.key, this.scanData});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  bool _isSaving = false;
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    // Agar history se nahi aaya toh auto-save karein
    if (widget.scanData != null && widget.scanData?['isFromHistory'] != true) {
      _saveToFirestore();
    }
  }

  void _shareResult() {
    String label = widget.scanData?['label'] ?? "Unknown";
    double accuracy = 0.0;
    var rawAccuracy = widget.scanData?['accuracy'];
    if (rawAccuracy is num) accuracy = rawAccuracy.toDouble();

    String shareText = "🚀 SKINSENTINEL PRO REPORT\n"
        "---------------------------\n"
        "Result: ${label.toUpperCase()}\n"
        "Confidence: ${accuracy.toStringAsFixed(1)}%\n\n"
        "Note: This is an AI-generated analysis. Consult a doctor.";
    Share.share(shareText);
  }

  Future<void> _saveToFirestore() async {
    if (_hasSaved || _isSaving) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('scans').add({
        'userId': user.uid,
        'label': widget.scanData?['label'] ?? "Unknown",
        'accuracy': widget.scanData?['accuracy'] ?? 0.0,
        'imageUrl': widget.scanData?['imageUrl'] ?? "",
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) setState(() => _hasSaved = true);
    } catch (e) {
      debugPrint("❌ Firebase Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String label = widget.scanData?['label']?.toString() ?? "UNKNOWN";
    bool isDanger = label.toLowerCase().contains('malignant');

    double accuracyValue = 0.0;
    var rawAccuracy = widget.scanData?['accuracy'];
    if (rawAccuracy is num) accuracyValue = rawAccuracy.toDouble();
    double displayProgress = accuracyValue > 1.0 ? accuracyValue / 100 : accuracyValue;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("ANALYSIS REPORT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        actions: [
          if (_hasSaved || widget.scanData?['isFromHistory'] == true)
            const Padding(
                padding: EdgeInsets.only(right: 15),
                child: Icon(Icons.cloud_done, color: Colors.greenAccent)
            )
        ],
      ),
      body: Stack(
        children: [
          // Subtle Background Orbs
          Positioned(top: -50, right: -50, child: _buildOrb(200, isDanger ? Colors.redAccent.withOpacity(0.05) : Colors.cyanAccent.withOpacity(0.05))),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                // Result Status Card
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDanger
                        ? Colors.redAccent.withOpacity(0.05)
                        : (isDarkMode ? Colors.cyanAccent : Colors.cyan).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: isDanger
                            ? Colors.redAccent.withOpacity(0.2)
                            : (isDarkMode ? Colors.cyanAccent : Colors.cyan).withOpacity(0.2)
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDanger ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                        size: 70,
                        color: isDanger ? Colors.redAccent : (isDarkMode ? Colors.cyanAccent : Colors.cyan[700]),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        isDanger ? "POTENTIAL RISK DETECTED" : "SCAN ANALYSIS COMPLETE",
                        style: TextStyle(
                            color: isDanger ? Colors.redAccent : (isDarkMode ? Colors.cyanAccent : Colors.cyan[700]),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Prediction Gauge
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      Text("AI PREDICTION",
                          style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black45, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Text(label.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black
                          )),
                      const SizedBox(height: 30),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                              height: 120,
                              width: 120,
                              child: CircularProgressIndicator(
                                  value: displayProgress,
                                  strokeWidth: 10,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: isDarkMode ? Colors.white10 : Colors.black12,
                                  color: isDanger ? Colors.redAccent : Colors.greenAccent
                              )
                          ),
                          Text("${(displayProgress * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ))
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Action Buttons
                _buildActionBtn(
                    context,
                    "FIND NEARBY CLINICS",
                    Icons.location_on_rounded,
                    Colors.redAccent,
                    false,
                        () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalMapScreen()));
                    }
                ),
                const SizedBox(height: 15),
                _buildActionBtn(
                    context,
                    "SHARE ANALYSIS",
                    Icons.share_rounded,
                    isDarkMode ? Colors.cyanAccent : Colors.cyan[700]!,
                    true,
                    _shareResult
                ),

                const SizedBox(height: 40),
                Text(
                    "Disclaimer: This AI analysis is for informational purposes only. Please consult a qualified dermatologist for a formal medical diagnosis.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black38, fontSize: 11, height: 1.4)
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, Color color, bool isOutlined, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: isOutlined
          ? OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
              side: BorderSide(color: color, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
          ),
          onPressed: onTap,
          icon: Icon(icon, color: color),
          label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold))
      )
          : ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.1),
              elevation: 0,
              side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
          ),
          onPressed: onTap,
          icon: Icon(icon, color: color),
          label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold))
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
    );
  }
}