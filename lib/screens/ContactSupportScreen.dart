import 'dart:ui';
import 'package:flutter/material.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Check Theme Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ Dynamic Background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- BACKGROUND GLOWS ---
          Positioned(top: -50, right: -50, child: _buildOrb(200, Colors.cyanAccent.withOpacity(0.1))),
          Positioned(bottom: 100, left: -50, child: _buildOrb(250, Colors.blueAccent.withOpacity(0.05))),

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
                        const SizedBox(height: 30),

                        // Main Support Icon with Glow
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              border: Border.all(color: Colors.cyanAccent.withOpacity(isDarkMode ? 0.2 : 0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(isDarkMode ? 0.1 : 0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                            child: Icon(Icons.headset_mic_rounded, size: 60, color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700]),
                          ),
                        ),

                        const SizedBox(height: 30),
                        Text(
                          "How can we help?",
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Our dedicated team is here to support you 24/7 with any queries.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black54, fontSize: 14, height: 1.5),
                        ),

                        const SizedBox(height: 50),

                        // --- CONTACT TILES ---
                        _buildContactTile(
                          context,
                          isDarkMode,
                          Icons.email_rounded,
                          "Email Us",
                          "support@skinsentinel.com",
                          Colors.orangeAccent,
                        ),
                        _buildContactTile(
                          context,
                          isDarkMode,
                          Icons.phone_iphone_rounded,
                          "Call Us",
                          "+92 317 5987431",
                          Colors.greenAccent,
                        ),
                        _buildContactTile(
                          context,
                          isDarkMode,
                          Icons.location_on_rounded,
                          "Visit Our Office",
                          "Tech Park, Silicon Valley, CA",
                          Colors.blueAccent,
                        ),

                        const SizedBox(height: 40),

                        // Feedback link or small text
                        Text(
                          "Average response time: < 2 hours",
                          style: TextStyle(
                              color: isDarkMode ? Colors.cyanAccent : Colors.cyan[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        const SizedBox(height: 30),
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

  // --- UI COMPONENTS ---

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
          Text("Support Center",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, bool isDark, IconData icon, String title, String sub, Color col) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: col.withOpacity(isDark ? 0.1 : 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: isDark ? col : col.withRed(150), size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(sub,
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.black54, fontSize: 13)),
              ],
            ),
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