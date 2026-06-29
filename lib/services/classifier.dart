import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart'; // rootBundle ke liye zaroori hai
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Classifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  // 1. Model aur Labels load karne ka sahi tareeka
  Future<void> loadModel() async {
    try {
      // Model load karein
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');

      // Labels load karein (Assets se)
      final labelsString = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsString.split('\n').where((s) => s.isNotEmpty).toList();

      print('✅ Model & Labels Loaded Successfully');
    } catch (e) {
      print('❌ Error loading model or labels: $e');
    }
  }

  // 2. Image ko 224x224 aur Float32 mein badalna
  Uint8List imageToByteListFloat32(img.Image image) {
    // 1 * 224 * 224 * 3 (Channels) * 4 (Bytes for Float32)
    var convertedBytes = Float32List(1 * 224 * 224 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        var pixel = image.getPixel(x, y);

        // Naye 'image' package mein pixel.r, pixel.g, pixel.b use hota hai
        buffer[pixelIndex++] = (pixel.r / 255.0);
        buffer[pixelIndex++] = (pixel.g / 255.0);
        buffer[pixelIndex++] = (pixel.b / 255.0);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  // 3. Prediction Function
  Future<String> predict(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      return "Model load nahi hua bhai!";
    }

    try {
      // Image read aur decode karein
      final imageData = imageFile.readAsBytesSync();
      img.Image? imageInput = img.decodeImage(imageData);

      if (imageInput == null) return "Image decode nahi ho saki";

      // Resize to 224x224 (Jo humne training mein rakha tha)
      img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);

      // Input aur Output Tensors tayyar karein
      var input = imageToByteListFloat32(resizedImage);
      var output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);

      // Model Run karein!
      _interpreter!.run(input, output);

      // Results nikalna — safe casting taake null/dynamic se crash na ho
      // output[0] dynamic hota hai; har element ko num? maan kar double mein convert karte hain
      final rawScores = (output[0] as List?) ?? const [];
      final List<double> result = rawScores
          .map((e) => (e as num?)?.toDouble() ?? 0.0)
          .toList();

      if (result.isEmpty) return "Koi prediction nahi mili";

      int maxIdx = 0;
      double maxProb = 0.0;

      for (int i = 0; i < result.length; i++) {
        if (result[i] > maxProb) {
          maxProb = result[i];
          maxIdx = i;
        }
      }

      // Final Answer — label missing ho toh gracefully fallback
      final labels = _labels ?? const <String>[];
      final String label = (maxIdx >= 0 && maxIdx < labels.length)
          ? (labels[maxIdx].toString().trim().isEmpty ? "Unknown" : labels[maxIdx])
          : "Unknown";
      String confidence = (maxProb * 100).toStringAsFixed(2);

      return "$label ($confidence%)";
    } catch (e) {
      return "Prediction Error: $e";
    }
  }

  // Model close karna taake memory leak na ho
  void close() {
    _interpreter?.close();
  }
}