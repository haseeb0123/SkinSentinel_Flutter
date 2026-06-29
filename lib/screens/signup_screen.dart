import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameController.text.trim());

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = "Registration failed";
        if (e.code == 'email-already-in-use') message = "Email already in use.";
        else if (e.code == 'weak-password') message = "Password is too weak.";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Adaptive Orbs
          Positioned(top: -100, right: -50, child: _buildOrb(300, Colors.cyanAccent.withOpacity(isDarkMode ? 0.08 : 0.15))),
          Positioned(bottom: -50, left: -50, child: _buildOrb(300, Colors.blueAccent.withOpacity(isDarkMode ? 0.05 : 0.1))),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Spacer(flex: 3),
                            _buildHeader(isDarkMode),
                            const Spacer(flex: 2),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Create Account",
                                  style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1
                                  )),
                            ),
                            const SizedBox(height: 25),

                            _buildTextField(_nameController, "Full Name", Icons.person_rounded, isDarkMode),
                            const SizedBox(height: 18),
                            _buildTextField(_emailController, "Email Address", Icons.email_rounded, isDarkMode, isEmail: true),
                            const SizedBox(height: 18),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                              decoration: _inputDecoration("Password", Icons.lock_rounded, isDarkMode).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: isDarkMode ? Colors.white38 : Colors.black38,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                              ),
                              validator: (value) => (value == null || value.length < 6) ? "Minimum 6 characters" : null,
                            ),

                            const SizedBox(height: 35),
                            _buildSignUpButton(),
                            const Spacer(flex: 3),
                            _buildFooter(isDarkMode),
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

          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDarkMode ? Colors.white : Colors.black87, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.1)),
          ),
          child: const Icon(Icons.person_add_alt_1_rounded, size: 65, color: Colors.cyanAccent),
        ),
        const SizedBox(height: 15),
        Text("Join SkinSentinel",
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2
            )),
        Text("Start your AI health journey", style: TextStyle(color: isDark ? Colors.white24 : Colors.black38, fontSize: 13)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black38, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.cyanAccent.withOpacity(0.7), size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF161925) : Colors.grey.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5)
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isDark, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: _inputDecoration(hint, icon, isDark),
      validator: (value) {
        if (value == null || value.isEmpty) return "$hint is required";
        if (isEmail && !value.contains('@')) return "Enter a valid email";
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: _isLoading
            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : const Text("SIGN UP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account? ", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text("Login", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container()),
    );
  }
}