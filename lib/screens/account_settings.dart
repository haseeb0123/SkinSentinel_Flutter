import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // ✅ Check Theme Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ Dynamic Background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- BACKGROUND ORBS ---
          Positioned(top: -50, left: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.08))),
          Positioned(bottom: 200, right: -100, child: _buildOrb(300, Colors.purpleAccent.withOpacity(0.05))),

          Column(
            children: [
              // Custom AppBar
              _buildCustomAppBar(context, isDarkMode),

              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(child: Text("User data not found", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
                    }

                    var userData = snapshot.data!.data() as Map<String, dynamic>;
                    String name = userData['name'] ?? "No Name";
                    String email = userData['email'] ?? "No Email";

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // --- PROFILE AVATAR WITH GLOW ---
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 130, height: 130,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [Colors.cyanAccent, Colors.cyanAccent.withOpacity(0.1)]),
                                  ),
                                  child: CircleAvatar(
                                    // ✅ Dynamic Avatar Background
                                    backgroundColor: isDarkMode ? const Color(0xFF10121D) : Colors.white,
                                    child: const Icon(Icons.person_rounded, size: 80, color: Colors.cyanAccent),
                                  ),
                                ),
                                _buildEditCircle(() => _showEditDialog(context, 'name', name, isDarkMode)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // --- INFO TILES ---
                          _buildPremiumInfoTile(context, isDarkMode, "Full Name", name, Icons.person_outline_rounded,
                              isEditable: true,
                              onEdit: () => _showEditDialog(context, 'name', name, isDarkMode)),

                          _buildPremiumInfoTile(context, isDarkMode, "Email Address", email, Icons.alternate_email_rounded,
                              isEditable: false),

                          _buildPremiumInfoTile(context, isDarkMode, "Account Status", "Premium Member", Icons.verified_user_outlined,
                              isEditable: false, accentColor: Colors.greenAccent),

                          const SizedBox(height: 40),
                          Text(
                            "Your personal information is secure and encrypted.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26, fontSize: 12),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, bool isDark) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            Text("Account Details", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumInfoTile(BuildContext context, bool isDark, String title, String value, IconData icon, {bool isEditable = false, VoidCallback? onEdit, Color accentColor = Colors.cyanAccent}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // ✅ Dynamic Card Color
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: accentColor.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 11, letterSpacing: 0.5)),
                Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (isEditable)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.edit_rounded, color: isDark ? Colors.white54 : Colors.black54, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditCircle(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle),
        child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.black),
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

  void _showEditDialog(BuildContext context, String field, String currentValue, bool isDark) {
    final TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          // ✅ Dynamic Dialog Background
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: BorderSide(color: Colors.cyanAccent.withOpacity(0.2))),
          title: Text("Edit ${field.toUpperCase()}", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18)),
          content: TextField(
            controller: controller,
            autofocus: true,
            // ✅ Dynamic Text Style
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({field: controller.text.trim()});
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Update", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}