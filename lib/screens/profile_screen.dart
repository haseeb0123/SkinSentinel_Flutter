import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'account_settings.dart';
import 'notification_settings.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileView();
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final user = FirebaseAuth.instance.currentUser;

  void _showLogoutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF161925) : Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(color: Colors.redAccent.withOpacity(0.2))
            ),
            title: Text("Logout",
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            content: Text("Are you sure you want to log out?",
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white54 : Colors.black45))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false
                    );
                  }
                },
                child: const Text("Logout"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- BACKGROUND GLOWS ---
          Positioned(top: -50, right: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.05))),
          Positioned(bottom: 100, left: -50, child: _buildOrb(200, Colors.purpleAccent.withOpacity(0.05))),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  children: [
                    Text("My Profile",
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1
                        )),
                    const SizedBox(height: 40),

                    // --- PROFILE HEADER ---
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  colors: [
                                    isDarkMode ? Colors.cyanAccent : Colors.cyan[700]!,
                                    Colors.purpleAccent.withOpacity(0.5)
                                  ]
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: isDarkMode ? const Color(0xFF10121D) : Colors.grey[200],
                              child: Icon(Icons.person_rounded,
                                  size: 60,
                                  color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700]),
                            ),
                          ),
                          const SizedBox(height: 20),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                            builder: (context, snapshot) {
                              // User summary ke mutabiq aapka professional name handle kiya gaya hai
                              String name = (snapshot.hasData && snapshot.data!.exists)
                                  ? (snapshot.data!.data() as Map<String, dynamic>)['name']
                                  : "Syed Sameer Ali"; // Default handle for profile consistency

                              return Column(
                                children: [
                                  Text(name,
                                      style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold
                                      )),
                                  Text(user?.email ?? "sameer@example.com",
                                      style: TextStyle(
                                          color: isDarkMode ? Colors.white38 : Colors.black45,
                                          fontSize: 14
                                      )),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- MENU ITEMS ---
                    _buildPremiumTile(
                      context,
                      isDarkMode,
                      icon: Icons.person_outline_rounded,
                      title: "Account Settings",
                      subtitle: "Change name, email, etc.",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsScreen())),
                    ),
                    const SizedBox(height: 15),
                    _buildPremiumTile(
                      context,
                      isDarkMode,
                      icon: Icons.notifications_none_rounded,
                      title: "Notifications",
                      subtitle: "Alerts & updates settings",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
                    ),

                    const SizedBox(height: 80),

                    // --- LOGOUT BUTTON ---
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                        elevation: 0,
                      ),
                      onPressed: () => _showLogoutDialog(context, isDarkMode),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text("Log Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTile(BuildContext context, bool isDark, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(icon, color: isDark ? Colors.cyanAccent : Colors.cyan[700]),
        ),
        title: Text(title,
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold
            )),
        subtitle: Text(subtitle,
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            color: isDark ? Colors.white24 : Colors.black26,
            size: 14),
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