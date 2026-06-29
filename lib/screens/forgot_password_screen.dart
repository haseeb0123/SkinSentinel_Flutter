import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Added Firebase Auth

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ✅ Controllers and Form Keys for Validation
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
 
  // --- REAL FIREBASE PASSWORD RESET METHOD ---
  Future<void> _resetPassword(BuildContext context, bool isDark) async {
    // 1. Check if Email field is valid
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 2. Send email link via Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        // 3. Show your premium dialog on success
        _showSuccessDialog(context, isDark);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";

      if (e.code == 'user-not-found') {
        errorMessage = "This email is not registered with us.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Please enter a valid email address.";
      } else if (e.code == 'network-request-failed') {
        errorMessage = "No internet connection detected.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- PREMIUM SUCCESS DIALOG ---
  void _showSuccessDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.cyanAccent.withOpacity(isDark ? 0.2 : 0.5)),
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mark_email_read_rounded,
                      color: isDark ? Colors.cyanAccent : Colors.cyan[700], size: 70),
                  const SizedBox(height: 25),
                  Text(
                    "Link Sent!",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "A password reset link has been sent to your email address. Please check your inbox.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // Dialog band
                        Navigator.pop(context); // Login screen par wapis
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.cyanAccent : Colors.cyan[700],
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "BACK TO LOGIN",
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
          // Background Glow Orbs
          Positioned(top: -50, left: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.08))),
          Positioned(bottom: 100, right: -50, child: _buildOrb(200, Colors.blueAccent.withOpacity(0.05))),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                _buildAppBar(context, isDarkMode),

                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: Form(
                              key: _formKey, // ✅ Wrapped in Form for validation
                              child: Column(
                                children: [
                                  const Spacer(flex: 1),

                                  // Lock Icon Container
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: (isDarkMode ? Colors.cyanAccent : Colors.cyan).withOpacity(0.1)),
                                        boxShadow: [
                                          BoxShadow(
                                              color: (isDarkMode ? Colors.cyanAccent : Colors.cyan).withOpacity(0.05),
                                              blurRadius: 20
                                          )
                                        ],
                                      ),
                                      child: Icon(Icons.lock_reset_rounded, size: 70, color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700]),
                                    ),
                                  ),

                                  const SizedBox(height: 40),
                                  Text(
                                    "Reset Password",
                                    style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    "Enter your email address below to receive a secure password reset link.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black54, fontSize: 14, height: 1.5),
                                  ),

                                  const SizedBox(height: 50),

                                  // Email Input
                                  TextFormField(
                                    controller: _emailController, // ✅ Controller linked
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                    cursorColor: isDarkMode ? Colors.cyanAccent : Colors.cyan[700],
                                    decoration: _inputDecoration(context, isDarkMode, "Email Address", Icons.email_rounded),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Email field cannot be empty";
                                      }
                                      // Simple Email Regex check
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                        return "Please enter a valid email address";
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 30),

                                  // Send Link Button
                                  Container(
                                    width: double.infinity,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                            color: (isDarkMode ? Colors.cyanAccent : Colors.cyan).withOpacity(0.15),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8)
                                        )
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : () => _resetPassword(context, isDarkMode), // ✅ Loading check
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDarkMode ? Colors.cyanAccent : Colors.cyan[700],
                                        foregroundColor: isDarkMode ? Colors.black : Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: isDarkMode ? Colors.black : Colors.white,
                                        ),
                                      )
                                          : const Text(
                                        "SEND RESET LINK",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                      ),
                                    ),
                                  ),

                                  const Spacer(flex: 2),

                                  // Bottom Footer
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Remember Password? ",
                                        style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black45, fontSize: 14),
                                        children: [
                                          TextSpan(
                                            text: "Login",
                                            style: TextStyle(
                                                color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700],
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, bool isDark, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black38, fontSize: 14),
      prefixIcon: Icon(icon, color: (isDark ? Colors.cyanAccent : Colors.cyan[700])!.withOpacity(0.7), size: 20),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05))
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: isDark ? Colors.cyanAccent : Colors.cyan[700]!, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
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