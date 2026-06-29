import 'package:flutter/material.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040508),
      appBar: AppBar(title: const Text("AI Scanner")),
      body: const Center(
        child: Text(
          "AI Scanner is optimized for Mobile Devices.\nPlease use the Android App for Skin Analysis.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}