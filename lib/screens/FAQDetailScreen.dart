import 'dart:ui';
import 'package:flutter/material.dart';

class FAQDetailScreen extends StatelessWidget {
  const FAQDetailScreen({super.key});

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
          Positioned(top: -50, left: -50, child: _buildOrb(200, Colors.purpleAccent.withOpacity(0.08))),
          Positioned(bottom: 100, right: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.05))),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                _buildAppBar(context, isDarkMode),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                        child: Text(
                          "Frequently Asked\nQuestions",
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2
                          ),
                        ),
                      ),

                      _buildExpandedFAQ(
                          context,
                          isDarkMode,
                          "How to scan my skin?",
                          "Go to the Home screen, click on the 'Scan' button, and take a clear photo of the affected area in good lighting. Make sure the image is not blurry."
                      ),
                      _buildExpandedFAQ(
                          context,
                          isDarkMode,
                          "Does it replace a doctor?",
                          "No. SkinSentinel is an AI assistant for guidance and early detection support. For any medical prescriptions or serious conditions, always consult a certified dermatologist."
                      ),
                      _buildExpandedFAQ(
                          context,
                          isDarkMode,
                          "How should I take the photo?",
                          "For the best AI results, ensure the area is well-lit (natural light is best) and the camera is in focus. Keep the skin area centered and avoid using flash if it creates a glare."
                      ),
                      _buildExpandedFAQ(
                          context,
                          isDarkMode,
                          "How to delete my data?",
                          "Your privacy is our priority. You can delete your scan history or your entire account and associated data from the 'Privacy & Security' settings."
                      ),

                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          "Still have questions? Contact Support",
                          style: TextStyle(color: isDarkMode ? Colors.white30 : Colors.black38, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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
          Text("FAQs",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildExpandedFAQ(BuildContext context, bool isDark, String ques, String ans) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
              ques,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)
          ),
          iconColor: isDark ? Colors.cyanAccent : Colors.cyan[700],
          collapsedIconColor: isDark ? Colors.white24 : Colors.black26,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  ans,
                  style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 14, height: 1.6)
              ),
            ),
          ],
        ),
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