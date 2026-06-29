import 'dart:ui';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Dynamic Theme Detection
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- BACKGROUND GLOWS ---
          Positioned(top: -50, right: -50, child: _buildOrb(200, Colors.purpleAccent.withOpacity(0.08))),
          Positioned(bottom: 100, left: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.05))),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                _buildAppBar(context, isDarkMode),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // --- NOTIFICATION LIST ---
                        _buildNotificationItem(
                          context,
                          isDarkMode,
                          title: "Analysis Ready",
                          message: "Your skin analysis report has been generated and saved to your history.",
                          time: "2 mins ago",
                          icon: Icons.analytics_rounded,
                          iconColor: isDarkMode ? Colors.cyanAccent : Colors.cyan[700]!,
                          isNew: true,
                        ),

                        _buildNotificationItem(
                          context,
                          isDarkMode,
                          title: "Specialist Alert",
                          message: "Medical feedback has been updated for your last request.",
                          time: "1 hour ago",
                          icon: Icons.medical_services_rounded,
                          iconColor: Colors.orangeAccent,
                          isNew: true,
                        ),

                        _buildNotificationItem(
                          context,
                          isDarkMode,
                          title: "Daily Tip",
                          message: "The UV index is high today. Don't forget to apply your SPF 50 sunscreen!",
                          time: "5 hours ago",
                          icon: Icons.wb_sunny_rounded,
                          iconColor: Colors.pinkAccent,
                          isNew: false,
                        ),

                        _buildNotificationItem(
                          context,
                          isDarkMode,
                          title: "Security Update",
                          message: "Your account security has been improved with new biometric features.",
                          time: "Yesterday",
                          icon: Icons.vibration_rounded,
                          iconColor: Colors.greenAccent,
                          isNew: false,
                        ),

                        const SizedBox(height: 30),

                        // --- BOTTOM STATUS CARD ---
                        _buildCaughtUpCard(context, isDarkMode),

                        const SizedBox(height: 50),
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
          Text("Activity Feed",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.done_all_rounded, color: isDark ? Colors.cyanAccent : Colors.cyan[700], size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context,
      bool isDark, {
        required String title,
        required String message,
        required String time,
        required IconData icon,
        required Color iconColor,
        required bool isNew,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
            color: isNew
                ? iconColor.withOpacity(isDark ? 0.3 : 0.5)
                : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
            width: isNew ? 1.5 : 1
        ),
        boxShadow: isNew ? [
          BoxShadow(color: iconColor.withOpacity(0.05), blurRadius: 15, spreadRadius: 2)
        ] : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 15),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const Spacer(),
                    if (isNew)
                      Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                            color: isDark ? Colors.cyanAccent : Colors.cyan[700],
                            shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(message,
                    style: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
                        fontSize: 13,
                        height: 1.4)),
                const SizedBox(height: 12),
                Text(time,
                    style: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.2) : Colors.black26,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaughtUpCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.grey[100],
        gradient: isDark ? LinearGradient(
          colors: [const Color(0xFF161925), const Color(0xFF040508)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded,
                color: isDark ? Colors.cyanAccent : Colors.cyan[700],
                size: 35),
          ),
          const SizedBox(height: 20),
          Text("You're all caught up!",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            "No more urgent notifications at this moment. We'll alert you when something's up!",
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 13, height: 1.5),
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