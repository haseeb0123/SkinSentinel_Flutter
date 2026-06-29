import 'dart:ui';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if current mode is dark
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ Dynamic Background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- BACKGROUND GLOWS ---
          Positioned(top: -50, left: -50, child: _buildOrb(200, Colors.cyanAccent.withOpacity(0.08))),
          Positioned(bottom: 100, right: -50, child: _buildOrb(250, Colors.blueAccent.withOpacity(0.05))),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                _buildAppBar(context, isDarkMode),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // --- APP LOGO SECTION ---
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  // ✅ Dynamic Card Color
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
                                  boxShadow: isDarkMode ? [
                                    BoxShadow(color: Colors.cyanAccent.withOpacity(0.05), blurRadius: 20)
                                  ] : [],
                                ),
                                child: const Icon(Icons.medical_services_rounded, color: Colors.cyanAccent, size: 60),
                              ),
                              const SizedBox(height: 20),
                              Text("SkinSentinel AI",
                                  style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1
                                  )),
                              Text("Version 1.0.2",
                                  style: TextStyle(
                                      color: isDarkMode ? Colors.white24 : Colors.black45,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  )),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // --- DESCRIPTION CARD ---
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            // ✅ Dynamic Container Color
                            color: Theme.of(context).cardColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
                          ),
                          child: Text(
                            "SkinSentinel is a state-of-the-art AI dermatological assistant. Our mission is to empower individuals with early skin condition detection using advanced neural networks and high-precision image analysis.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                                fontSize: 14,
                                height: 1.6
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // --- KEY FEATURES SECTION ---
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Core Technologies",
                              style: TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 20),

                        _buildFeatureCard(context, isDarkMode, Icons.auto_awesome_rounded, "Advanced AI Analysis", "CNN-based dermatological detection."),
                        _buildFeatureCard(context, isDarkMode, Icons.security_rounded, "Encrypted Data", "AES-256 local data protection."),
                        _buildFeatureCard(context, isDarkMode, Icons.history_rounded, "Timeline Tracking", "Monitor skin changes over time."),

                        const SizedBox(height: 40),
                        Divider(color: isDarkMode ? Colors.white10 : Colors.black),
                        const SizedBox(height: 20),

                        // --- CONTACT & PARTNERS ---
                        _buildInfoTile(isDarkMode, Icons.alternate_email_rounded, "Technical Support", "support@skinsentinel.com"),
                        _buildInfoTile(isDarkMode, Icons.local_hospital_rounded, "Clinical Partner", "General Hospital, Lahore"),

                        const SizedBox(height: 50),
                        Text("© 2026 SkinSentinel AI. All rights reserved.",
                            style: TextStyle(
                                color: isDarkMode ? Colors.white12 : Colors.black26,
                                fontSize: 11,
                                letterSpacing: 0.5
                            )),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text("About Us",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, bool isDark, IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        // ✅ Dynamic Card Color
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc, style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(bool isDark, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent.withOpacity(0.7), size: 22),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
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