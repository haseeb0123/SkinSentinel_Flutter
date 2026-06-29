import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- ADAPTIVE BACKGROUND EFFECTS ---
          Positioned(top: -50, left: -50, child: _buildBackgroundOrb(250, const Color(0xFF6A11CB).withOpacity(isDarkMode ? 0.2 : 0.1))),
          Positioned(bottom: 100, right: -50, child: _buildBackgroundOrb(200, const Color(0xFF2575FC).withOpacity(isDarkMode ? 0.15 : 0.08))),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('scans')
                .where('userId', isEqualTo: user?.uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
              }

              final docs = snapshot.data?.docs ?? [];
              int totalScans = docs.length;
              double avgAccuracy = 0.0;
              if (totalScans > 0) {
                double sum = 0;
                for (var doc in docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  var acc = data['accuracy'];
                  if (acc is num) sum += acc.toDouble();
                }
                avgAccuracy = sum / totalScans;
              }

              return SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      Center(
                        child: Text("Health Analytics",
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5
                            )),
                      ),
                      const SizedBox(height: 35),

                      // --- ANIMATED MAIN SCORE CARD ---
                      _buildAnimatedMainCard(avgAccuracy),

                      const SizedBox(height: 40),
                      Text("Performance Metrics",
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),

                      _buildGlassStatCard("Total Scans", "$totalScans", (totalScans / 100).clamp(0.0, 1.0), Icons.analytics_rounded, Colors.cyanAccent, isDarkMode),
                      _buildGlassStatCard("Avg. Accuracy", "${avgAccuracy.toStringAsFixed(1)}%", (avgAccuracy / 100).clamp(0.0, 1.0), Icons.verified_user_rounded, Colors.purpleAccent, isDarkMode),

                      const SizedBox(height: 35),
                      Text("Recent Activity",
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 15),

                      if (docs.isEmpty)
                        Center(child: Padding(padding: const EdgeInsets.only(top: 20), child: Text("No data available", style: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26))))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length > 5 ? 5 : docs.length,
                          itemBuilder: (context, index) {
                            var data = docs[index].data() as Map<String, dynamic>;
                            DateTime? date = (data['timestamp'] as Timestamp?)?.toDate();
                            String timeString = date != null ? DateFormat('MMM d, h:mm a').format(date) : "Recent";

                            return _buildActivityTile(
                                data['label'] ?? "Analysis",
                                timeString,
                                "${(data['accuracy'] ?? 0.0).toStringAsFixed(1)}%",
                                (data['label']?.toString().toLowerCase().contains('malignant') ?? false) ? Colors.redAccent : Colors.cyanAccent,
                                isDarkMode
                            );
                          },
                        ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMainCard(double score) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(color: const Color(0xFF6A11CB).withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))
            ],
          ),
          child: Column(
            children: [
              const Text("Overall Health Index", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 25),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140, height: 140,
                    child: CircularProgressIndicator(
                      value: (score / 100) * _progressAnimation.value,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Column(
                    children: [
                      Text("${(score * _progressAnimation.value).toInt()}%",
                          style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
                      const Text("Accuracy", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassStatCard(String title, String value, double progress, IconData icon, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 15),
              Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 15)),
              const Spacer(),
              Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 18),
          Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(10))),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: progress * _progressAnimation.value,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color, color.withOpacity(0.5)]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 5)],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(String title, String time, String status, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(Icons.history_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(time, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildBackgroundOrb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
    );
  }
}