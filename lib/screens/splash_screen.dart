import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Fix: Curves.easeOutBack use kiya hai jo error de raha tha
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF040508) : Colors.grey[50],
      body: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _buildOrb(300, Colors.cyanAccent.withOpacity(isDarkMode ? 0.1 : 0.2))),
          Positioned(bottom: -50, left: -50, child: _buildOrb(300, Colors.blueAccent.withOpacity(isDarkMode ? 0.08 : 0.15))),

          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(isDarkMode ? 0.15 : 0.3),
                            blurRadius: 80,
                            spreadRadius: 20,
                          )
                        ],
                      ),
                      child: const Icon(Icons.security_rounded, size: 100, color: Colors.cyanAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "SkinSentinel AI",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 30,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Your AI Skin Guardian',
                        textStyle: TextStyle(
                          fontSize: 16.0,
                          color: isDarkMode ? Colors.white38 : Colors.black45,
                          letterSpacing: 1.2,
                        ),
                        speed: const Duration(milliseconds: 80),
                      ),
                    ],
                    isRepeatingAnimation: false,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent))),
                const SizedBox(height: 20),
                Text("SECURE ANALYSIS", style: TextStyle(color: isDarkMode ? Colors.white12 : Colors.black12, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3)),
                const SizedBox(height: 50),
              ],
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
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container()),
    );
  }
}