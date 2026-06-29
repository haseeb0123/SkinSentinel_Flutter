import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dashboard.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
    });
    if (_isBiometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleBiometricLogin());
    }
  }

  Future<void> _handleBiometricLogin() async {
    final localAuth = LocalAuthentication();
    try {
      bool didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Scan fingerprint to Login',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );

      if (didAuthenticate && mounted) {
        String? savedEmail = await _storage.read(key: 'user_email');
        String? savedPassword = await _storage.read(key: 'user_password');

        if (savedEmail != null && savedPassword != null) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: savedEmail, password: savedPassword);
          HapticFeedback.mediumImpact();
          if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
        }
      }
    } catch (e) {
      debugPrint("Biometric Error: $e");
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'user_password', value: password);
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
      } on FirebaseAuthException catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Error"), backgroundColor: Colors.redAccent));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        setState(() => _isLoading = true);
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
              shape: BoxShape.circle,
              border: Border.all(color: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.1))
          ),
          child: Icon(Icons.shield_moon_rounded, size: 60, color: isDark ? Colors.cyanAccent : Colors.cyan[700]),
        ),
        const SizedBox(height: 10),
        Text("SkinSentinel",
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        Text("Your AI Skin Guardian",
            style: TextStyle(color: isDark ? Colors.white24 : Colors.black38, fontSize: 12)),
      ],
    );
  }

  Widget _buildTextFields(BuildContext context, bool isDark) {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: _inputDecoration(context, isDark, "Email Address", Icons.email_rounded),
          validator: (value) => (value == null || !value.contains('@')) ? "Invalid email format" : null,
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: _inputDecoration(context, isDark, "Password", Icons.lock_rounded).copyWith(
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: isDark ? Colors.white38 : Colors.black26, size: 18),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          validator: (value) => (value == null || value.length < 6) ? "Minimum 6 characters required" : null,
        ),
      ],
    );
  }

  Widget _buildLoginSection(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))
                    ]
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.cyanAccent : Colors.cyan[700],
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  child: _isLoading
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: isDark ? Colors.black : Colors.white, strokeWidth: 2))
                      : const Text("LOGIN", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            if (_isBiometricEnabled) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _handleBiometricLogin,
                child: Container(
                  height: 55, width: 55,
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))
                  ),
                  child: const Icon(Icons.fingerprint_rounded, color: Colors.orangeAccent, size: 28),
                ),
              ),
            ]
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
            child: Text("Forgot Password?",
                style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.cyan[700], fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(bool isDark) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        icon: Image.asset('assets/images/google.png', height: 20),
        label: Text("Sign in with Google", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.02)
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, bool isDark, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black38, fontSize: 14),
      prefixIcon: Icon(icon, color: (isDark ? Colors.cyanAccent : Colors.cyan[700])!.withOpacity(0.7), size: 18),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05))
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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(top: -100, left: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.08))),
          Positioned(bottom: -50, right: -50, child: _buildOrb(250, Colors.purpleAccent.withOpacity(0.05))),
          SafeArea(
            child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              _buildHeader(isDarkMode),
                              const Spacer(), // Flexible space
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Welcome Back",
                                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold))),
                              const SizedBox(height: 20),
                              _buildTextFields(context, isDarkMode),
                              const SizedBox(height: 15),
                              _buildLoginSection(isDarkMode),
                              const Spacer(),
                              Text("OR CONTINUE WITH",
                                  style: TextStyle(color: isDarkMode ? Colors.white12 : Colors.black12, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              const SizedBox(height: 20),
                              _buildGoogleButton(isDarkMode),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Don't have an account? ", style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 13)),
                                    GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                                      child: Text("Sign Up",
                                          style: TextStyle(color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700], fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}