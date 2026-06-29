import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() => _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // ✅ Check Theme Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Email fetching and masking logic
    String userEmail = user?.email ?? "Guest User";
    String maskedEmail = userEmail;

    if (userEmail.contains("@") && userEmail != "Guest User") {
      var parts = userEmail.split("@");
      // ✅ Fixed the 'Part 0' error here
      maskedEmail = "${parts[0].substring(0, parts[0].length > 3 ? 3 : 1)}***@${parts[1]}";
    }

    return Scaffold(
      // ✅ Dynamic Background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -80, right: -50, child: _buildOrb(250, Colors.greenAccent.withOpacity(0.08))),
          Positioned(bottom: -50, left: -50, child: _buildOrb(200, Colors.cyanAccent.withOpacity(0.05))),

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
                        _buildGlowingAvatar(isDarkMode),
                        const SizedBox(height: 25),
                        Text("Status: Fully Verified",
                            style: TextStyle(
                                color: isDarkMode ? Colors.greenAccent : Colors.green[700],
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            )),
                        const SizedBox(height: 40),

                        // Verification Details
                        _buildVerifyDetail(context, isDarkMode, "Identity Verification", "Verified via Official ID", Icons.badge_rounded, Colors.blueAccent),
                        _buildVerifyDetail(context, isDarkMode, "Email Address", maskedEmail, Icons.email_rounded, Colors.orangeAccent),
                        _buildVerifyDetail(context, isDarkMode, "Phone Number", "+92 300 *******", Icons.phone_iphone_rounded, Colors.purpleAccent),

                        const SizedBox(height: 40),
                        _buildInfoBox(context, isDarkMode),
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
          Expanded(
            child: Center(
              child: Text("Account Verification",
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildGlowingAvatar(bool isDark) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 2),
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: isDark ? const Color(0xFF161925) : Colors.white,
            child: const Icon(Icons.person_rounded, size: 65, color: Colors.greenAccent),
          ),
        ),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.greenAccent,
          child: Icon(Icons.check, color: Colors.black, size: 20),
        ),
      ],
    );
  }

  Widget _buildVerifyDetail(BuildContext context, bool isDark, String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 11)),
                Text(subtitle, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
        ],
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.cyanAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Your identity is verified to ensure secure medical data processing.",
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black87, fontSize: 12),
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