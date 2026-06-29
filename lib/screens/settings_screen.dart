import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added for persistence
import '../main.dart';
import 'privacy_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';
import 'scan_history_screen.dart';
import 'account_verification_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ✅ Helper function theme save karne ke liye
  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- BACKGROUND NEON GLOWS ---
          Positioned(top: -50, left: -50, child: _buildOrb(200, Colors.cyanAccent.withOpacity(isDarkMode ? 0.1 : 0.05))),
          Positioned(bottom: 100, right: -50, child: _buildOrb(250, Colors.blueAccent.withOpacity(isDarkMode ? 0.08 : 0.04))),

          SafeArea(
            child: Column(
              children: [
                // Custom Premium AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      "Settings",
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: isDarkMode
                              ? [Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10)]
                              : []
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildStatusCard(isDarkMode),
                        const SizedBox(height: 30),

                        // APPEARANCE SECTION
                        _buildSectionLabel("APPEARANCE", isDarkMode),

                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: themeNotifier,
                          builder: (context, currentMode, child) {
                            bool isDark = currentMode == ThemeMode.dark;
                            return _buildThemeTile(
                              context,
                              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              iconColor: isDark ? Colors.purpleAccent : Colors.orangeAccent,
                              title: isDark ? "Dark Mode" : "Light Mode",
                              value: isDark,
                              onChanged: (val) async {
                                // ✅ 1. UI update karo
                                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                                // ✅ 2. Memory mein save karo
                                await _saveThemePreference(val);
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 25),

                        // GENERAL SETTINGS SECTION
                        _buildSectionLabel("GENERAL SETTINGS", isDarkMode),

                        _buildSettingTile(
                          context,
                          isDarkMode,
                          icon: Icons.history_rounded,
                          iconColor: Colors.blueAccent,
                          title: "Scan History",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanHistoryScreen())),
                        ),

                        _buildSettingTile(
                          context,
                          isDarkMode,
                          icon: Icons.verified_user_outlined,
                          iconColor: Colors.greenAccent,
                          title: "Account Verification",
                          trailingText: "Verified",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountVerificationScreen())),
                        ),

                        _buildSettingTile(
                          context,
                          isDarkMode,
                          icon: Icons.shield_outlined,
                          iconColor: Colors.cyanAccent,
                          title: "Privacy & Security",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyScreen())),
                        ),

                        _buildSettingTile(
                          context,
                          isDarkMode,
                          icon: Icons.help_outline_rounded,
                          iconColor: Colors.orangeAccent,
                          title: "Help & Support",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen())),
                        ),

                        _buildSettingTile(
                          context,
                          isDarkMode,
                          icon: Icons.info_outline_rounded,
                          iconColor: Colors.lightBlueAccent,
                          title: "About SkinSentinel",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen())),
                        ),

                        const SizedBox(height: 40),
                        Text(
                            "SkinSentinel v1.0.2",
                            style: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26, fontSize: 12, fontWeight: FontWeight.w500)
                        ),
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

  // --- WIDGET BUILDERS REMAIN THE SAME ---
  Widget _buildSectionLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 15),
        child: Text(
          text,
          style: TextStyle(
              color: isDark ? Colors.white24 : Colors.black38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5
          ),
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161925) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.cyanAccent,
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: isDark ? const Color(0xFF161925) : Colors.white,
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10)
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Account Status", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Profile is 100% complete", style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.2))
            ),
            child: const Text("Active", style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? trailingText,
    required VoidCallback onTap
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161925) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(trailingText, style: TextStyle(color: iconColor.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70), child: Container()),
    );
  }
}