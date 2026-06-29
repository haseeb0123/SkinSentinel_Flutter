import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Fixed: Red lines hatane ke liye isay StatelessWidget banaya hai
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Isay const call karna behtar hai kyunke PrivacyView ka constructor const hai
    return const PrivacyView();
  }
}

class PrivacyView extends StatefulWidget {
  const PrivacyView({super.key});

  @override
  State<PrivacyView> createState() => _PrivacyViewState();
}

class _PrivacyViewState extends State<PrivacyView> {
  bool isTwoFactor = true;
  bool isAppLock = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ✅ Settings load karne ka logic
  Future<void> _loadSettings() async {
    bool enabled = await BiometricHelper.isEnabled();
    setState(() {
      isAppLock = enabled;
    });
  }

  // ✅ Biometric toggle handling
  Future<void> _handleBiometricToggle(bool val) async {
    if (val) {
      bool authenticated = await BiometricHelper.authenticate();
      if (authenticated) {
        setState(() => isAppLock = true);
        await BiometricHelper.setBiometricEnabled(true);
        _showSnackBar("Biometric Lock Enabled", Colors.green);
      } else {
        setState(() => isAppLock = false);
        _showSnackBar("Authentication Failed", Colors.redAccent);
      }
    } else {
      setState(() => isAppLock = false);
      await BiometricHelper.setBiometricEnabled(false);
      _showSnackBar("Biometric Lock Disabled", Colors.orange);
    }
  }

  void _showSnackBar(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _buildOrb(200, Colors.blueAccent.withOpacity(0.1))),
          Positioned(bottom: 100, left: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.05))),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isDarkMode),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isDarkMode ? Colors.cyanAccent : Colors.cyan).withOpacity(0.05),
                              border: Border.all(color: (isDarkMode ? Colors.cyanAccent : Colors.cyan).withOpacity(0.1)),
                            ),
                            child: Icon(Icons.shield_rounded,
                                color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700],
                                size: 60),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text("Privacy & Security",
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                            )),
                        Text("Manage your data protection settings",
                            style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black45, fontSize: 13)),
                        const SizedBox(height: 40),

                        _buildToggleTile(
                          context,
                          isDarkMode,
                          "Two-Factor Auth",
                          Icons.vibration_rounded,
                          isDarkMode ? Colors.cyanAccent : Colors.cyan[700]!,
                          isTwoFactor,
                              (bool val) => setState(() => isTwoFactor = val),
                        ),

                        _buildInteractiveTile(
                          context,
                          isDarkMode,
                          "Data Encryption",
                          Icons.enhanced_encryption_rounded,
                          Colors.greenAccent,
                          Text("Active",
                              style: TextStyle(
                                  color: isDarkMode ? Colors.greenAccent : Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                              )),
                          onTap: () => _showEncryptionInfo(isDarkMode),
                        ),

                        _buildToggleTile(
                          context,
                          isDarkMode,
                          "App Lock",
                          Icons.fingerprint_rounded,
                          Colors.orangeAccent,
                          isAppLock,
                              (bool val) => _handleBiometricToggle(val),
                        ),

                        const SizedBox(height: 50),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
                          ),
                          child: Text(
                            "SkinSentinel uses AES-256 military-grade encryption to ensure your medical photos and history are 100% private.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 12, height: 1.5),
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

  // --- UI Components ---
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
          Text("Security Center",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildToggleTile(BuildContext context, bool isDark, String title, IconData icon, Color col, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: col, size: 20),
          ),
          const SizedBox(width: 15),
          Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
          const Spacer(),
          Switch(
            value: value,
            activeColor: col,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveTile(BuildContext context, bool isDark, String title, IconData icon, Color col, Widget trailing, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: col, size: 20),
            ),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
            const Spacer(),
            trailing,
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 14),
          ],
        ),
      ),
    );
  }

  void _showEncryptionInfo(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_person_rounded, color: isDark ? Colors.greenAccent : Colors.green[700], size: 50),
            const SizedBox(height: 20),
            Text("End-to-End Encryption",
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(
              "Your photos are encrypted with AES-256 before they even leave your device. Only you can access your scan results.",
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.greenAccent : Colors.green[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text("I UNDERSTAND",
                  style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
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

// --- Biometric Helper ---
class BiometricHelper {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      if (!canCheck && !isSupported) return false;

      return await _auth.authenticate(
        localizedReason: 'Secure your SkinSentinel profile',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  static Future<void> setBiometricEnabled(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBiometricEnabled', status);
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isBiometricEnabled') ?? false;
  }
}