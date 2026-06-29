import 'dart:ui';
import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Toggle states for settings
  bool pushNotifications = true;
  bool emailUpdates = false;
  bool analysisAlerts = true;
  bool dailyTips = true;

  @override
  Widget build(BuildContext context) {
    // ✅ Dynamic Theme Detection
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- BACKGROUND GLOWS ---
          Positioned(top: -50, right: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.08))),
          Positioned(bottom: 100, left: -50, child: _buildOrb(200, Colors.purpleAccent.withOpacity(0.05))),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isDarkMode),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "Preference Settings",
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          "Manage how you receive updates and alerts",
                          style: TextStyle(
                              color: isDarkMode ? Colors.white38 : Colors.black45,
                              fontSize: 13
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- SETTINGS TILES ---
                        _buildSettingTile(
                          context,
                          isDarkMode,
                          title: "Push Notifications",
                          subtitle: "Receive instant alerts on your device",
                          icon: Icons.notifications_active_outlined,
                          value: pushNotifications,
                          onChanged: (val) => setState(() => pushNotifications = val),
                        ),

                        _buildSettingTile(
                          context,
                          isDarkMode,
                          title: "Email Updates",
                          subtitle: "Weekly skin health reports via email",
                          icon: Icons.alternate_email_rounded,
                          value: emailUpdates,
                          onChanged: (val) => setState(() => emailUpdates = val),
                        ),

                        _buildSettingTile(
                          context,
                          isDarkMode,
                          title: "Analysis Alerts",
                          subtitle: "Get notified when AI scan is ready",
                          icon: Icons.analytics_outlined,
                          value: analysisAlerts,
                          onChanged: (val) => setState(() => analysisAlerts = val),
                        ),

                        _buildSettingTile(
                          context,
                          isDarkMode,
                          title: "Daily Skincare Tips",
                          subtitle: "UV alerts and personalized advice",
                          icon: Icons.lightbulb_outline_rounded,
                          value: dailyTips,
                          onChanged: (val) => setState(() => dailyTips = val),
                        ),

                        const SizedBox(height: 40),

                        // --- SAVE BUTTON ---
                        Center(
                          child: Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                  colors: isDarkMode
                                      ? [Colors.cyanAccent, Colors.blueAccent]
                                      : [Colors.cyan[700]!, Colors.blue[800]!]
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8)
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: Text(
                                  "SAVE PREFERENCES",
                                  style: TextStyle(
                                      color: isDarkMode ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1
                                  )
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black,
                size: 20
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
              "Notification Settings",
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              )
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
      BuildContext context,
      bool isDark, {
        required String title,
        required String subtitle,
        required IconData icon,
        required bool value,
        required ValueChanged<bool> onChanged
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.05),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Icon(
                icon,
                color: isDark ? Colors.cyanAccent : Colors.cyan[700],
                size: 22
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    title,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    )
                ),
                Text(
                    subtitle,
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black45,
                        fontSize: 11
                    )
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isDark ? Colors.cyanAccent : Colors.cyan[700],
            activeTrackColor: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.2),
            inactiveThumbColor: isDark ? Colors.white24 : Colors.grey[400],
            inactiveTrackColor: isDark ? Colors.white10 : Colors.grey[200],
          ),
        ],
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