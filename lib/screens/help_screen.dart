import 'dart:ui';
import 'package:flutter/material.dart';
import 'ContactSupportScreen.dart';
import 'FAQDetailScreen.dart';
import 'ReportBugScreen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text("How can we\nhelp you?",
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.2
                            )),
                        const SizedBox(height: 30),

                        // --- HELP CARDS ---
                        _buildHelpCard(
                            context,
                            isDarkMode,
                            "Contact Support",
                            "Our team is available 24/7",
                            Icons.headset_mic_rounded,
                            isDarkMode ? Colors.cyanAccent : Colors.cyan[700]!,
                            const ContactSupportScreen()
                        ),

                        _buildHelpCard(
                            context,
                            isDarkMode,
                            "General FAQs",
                            "Find quick answers here",
                            Icons.question_answer_rounded,
                            Colors.purpleAccent,
                            const FAQDetailScreen()
                        ),

                        _buildHelpCard(
                            context,
                            isDarkMode,
                            "Report a Bug",
                            "Help us improve SkinSentinel",
                            Icons.bug_report_rounded,
                            Colors.redAccent,
                            const ReportBugScreen()
                        ),

                        const SizedBox(height: 40),
                        Text("Common Questions",
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            )),
                        const SizedBox(height: 15),

                        // --- FAQ SECTION ---
                        _buildFAQ(
                            context,
                            isDarkMode,
                            "How accurate is the AI analysis?",
                            "Our AI is trained on thousands of dermatological images. It provides guidance with high precision, but we always recommend consulting a human doctor for medical prescriptions."
                        ),
                        _buildFAQ(
                            context,
                            isDarkMode,
                            "Is my data safe?",
                            "Absolutely. Your photos are encrypted locally using AES-256 and are only used for the duration of the analysis."
                        ),

                        const SizedBox(height: 40),
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

  Widget _buildHelpCard(BuildContext context, bool isDark, String title, String sub, IconData icon, Color col, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: col.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
            ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: col.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: col, size: 26),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(sub, style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white12 : Colors.black12, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ(BuildContext context, bool isDark, String ques, String ans) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          iconColor: isDark ? Colors.cyanAccent : Colors.cyan[700],
          collapsedIconColor: isDark ? Colors.white24 : Colors.black26,
          title: Text(ques, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          children: [
            Text(ans, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13, height: 1.5))
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