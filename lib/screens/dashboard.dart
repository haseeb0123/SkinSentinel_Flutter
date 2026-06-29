import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- CONDITIONAL IMPORT ---
import 'scanner_web.dart' if (dart.library.io) 'scanner_screen.dart';

// Screens imports
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'daily_care_screen.dart';
import 'Ahmad_detail.dart';
import 'Akbar_detail.dart';
import 'admin_panel.dart';
import 'ai_chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 600), curve: Curves.easeOutQuart);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: _buildOrb(300, Colors.cyanAccent.withOpacity(isDarkMode ? 0.08 : 0.15))),
          Positioned(bottom: 100, left: -50, child: _buildOrb(250, Colors.purpleAccent.withOpacity(isDarkMode ? 0.05 : 0.1))),

          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            children: [
              _buildHomeScreen(context, isDarkMode),
              const StatsScreen(),
              const DailyCareScreen(),
              const ProfileScreen(),
              const SettingsScreen(),
            ],
          ),
        ],
      ),

      floatingActionButton: Container(
        height: 65,
        width: 65,
        margin: const EdgeInsets.only(bottom: 80),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.cyanAccent : Colors.cyan).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: isDarkMode ? const Color(0xFF0D1117) : Colors.white,
          elevation: 10,
          shape: CircleBorder(side: BorderSide(color: (isDarkMode ? Colors.cyanAccent : Colors.cyan).withOpacity(0.6), width: 1.5)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AIChatScreen()),
            );
          },
          child: Icon(
            Icons.auto_awesome_rounded,
            color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700],
            size: 32,
          ),
        ),
      ),
      bottomNavigationBar: _buildFuturisticNav(context, isDarkMode),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
    );
  }

  Widget _buildHomeScreen(BuildContext context, bool isDark) {
    final User? user = FirebaseAuth.instance.currentUser;
    String displayName = user?.displayName ?? user?.email?.split('@')[0] ?? "User";

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Space fix
          children: [
            _buildHeader(displayName, isDark),
            const SizedBox(height: 30),
            _buildScannerCard(context, isDark),
            const SizedBox(height: 30),

            // Today's Skin Care Card
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.1),
                    Colors.transparent
                  ]),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: isDark ? Colors.cyanAccent : Colors.cyan[700], size: 24),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TODAY'S SKIN CARE", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                        Text("Check advice from Admin", style: TextStyle(color: isDark ? Colors.white.withOpacity(0.4) : Colors.black45, fontSize: 11)),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: isDark ? Colors.cyanAccent : Colors.cyan[700]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 35),
            Text("Recent Analysis", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10), // Gap kam kiya

            // --- RECENT ANALYSIS LIST ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scans')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                int totalScansCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                final docs = snapshot.data?.docs ?? [];

                return Column(
                  mainAxisSize: MainAxisSize.min, // Space fix
                  children: [
                    if (docs.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.history_rounded, color: isDark ? Colors.white10 : Colors.black12, size: 40),
                            const SizedBox(height: 10),
                            Text("No recent analysis found.", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 13)),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        padding: EdgeInsets.zero, // Extra padding khatam
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length > 4 ? 4 : docs.length,
                        itemBuilder: (context, index) {
                          var doc = docs[index];
                          var data = doc.data() as Map<String, dynamic>;

                          String result = data['label'] ?? data['result'] ?? "Skin Analysis";
                          double accVal = (data['accuracy'] is num) ? data['accuracy'].toDouble() : 0.0;
                          if (accVal > 0 && accVal <= 1.0) accVal *= 100;
                          String accuracyStr = accVal.toStringAsFixed(1);

                          String dateStr = "Recent";
                          if(data['timestamp'] != null) {
                            DateTime dt = (data['timestamp'] as Timestamp).toDate();
                            dateStr = "${dt.day}/${dt.month}/${dt.year}";
                          }

                          return _buildRealAnalysisTile(context, isDark, result, dateStr, accuracyStr, data);
                        },
                      ),

                    const SizedBox(height: 20), // Gap control
                    // --- UPDATED METRIC CARDS ---
                    Row(
                      children: [
                        _buildMetricCard(context, isDark, "Total Scans", totalScansCount.toString(), Icons.analytics_outlined, Colors.blueAccent),
                        const SizedBox(width: 15),
                        _buildMetricCard(context, isDark, "Risk Level", "Medium", Icons.warning_amber_rounded, Colors.orangeAccent),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildRealAnalysisTile(BuildContext context, bool isDark, String title, String date, String accuracy, Map<String, dynamic> data) {
    bool isNormal = title.toLowerCase().contains("normal") || title.toLowerCase().contains("healthy");
    String imageUrl = data['imageUrl'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.05)),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => isNormal
              ? AkbarDetailScreen(resultName: title, date: date, confidence: "$accuracy%", imageUrl: imageUrl)
              : AhmadDetailScreen(resultName: title, date: date, confidence: "$accuracy%", imageUrl: imageUrl)
          ));
        },
        leading: Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: (imageUrl.isNotEmpty && imageUrl.startsWith('http'))
                ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 20))
                : Icon(Icons.analytics_outlined, color: isNormal ? (isDark ? Colors.cyanAccent : Colors.cyan[700]) : Colors.orangeAccent, size: 24),
          ),
        ),
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text("$date • $accuracy% Accuracy", style: TextStyle(color: isDark ? Colors.white24 : Colors.black45, fontSize: 11)),
        trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 20),
      ),
    );
  }

  Widget _buildHeader(String name, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          CircleAvatar(
              radius: 24,
              backgroundColor: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.1),
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : "U", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.cyan[700]))
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Hello,", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
            Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold))
          ]),
        ]),
        Row(children: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/admin'), icon: Icon(Icons.security_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 22)),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> const NotificationsScreen())), icon: Icon(Icons.notifications_none_rounded, color: isDark ? Colors.cyanAccent : Colors.cyan[700])),
        ]),
      ],
    );
  }

  Widget _buildFuturisticNav(BuildContext context, bool isDark) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF10121D).withOpacity(0.95) : Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
          ]
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _futuristicNavItem(isDark, Icons.grid_view_rounded, "Home", 0),
        _futuristicNavItem(isDark, Icons.analytics_outlined, "Stats", 1),
        _futuristicNavItem(isDark, Icons.spa_rounded, "Care Hub", 2),
        _futuristicNavItem(isDark, Icons.person_2_rounded, "Profile", 3),
        _futuristicNavItem(isDark, Icons.settings_rounded, "Settings", 4),
      ]),
    );
  }

  Widget _futuristicNavItem(bool isDark, IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    Color activeCol = isDark ? Colors.cyanAccent : Colors.cyan[700]!;
    return GestureDetector(
        onTap: () => _onItemTapped(index),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: isSelected ? activeCol.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: isSelected ? activeCol : (isDark ? Colors.white24 : Colors.black26), size: 28),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? activeCol : (isDark ? Colors.white24 : Colors.black26), fontSize: 10))
            ])
        )
    );
  }

  Widget _buildScannerCard(BuildContext context, bool isDark) {
    return SizedBox(height: 220, width: double.infinity, child: Stack(children: [
      AnimatedBuilder(animation: _pulseController, builder: (context, child) => Center(child: Container(width: 180 + (_pulseController.value * 40), height: 180 + (_pulseController.value * 40), decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.1), blurRadius: 40, spreadRadius: 20)])))),
      Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(33), color: isDark ? const Color(0xFF10121D) : Colors.white, border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)), boxShadow: [if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.qr_code_scanner_rounded, size: 50, color: isDark ? Colors.cyanAccent : Colors.cyan[700]),
        const SizedBox(height: 10),
        Text("AI Diagnosis", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen())), style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.cyanAccent : Colors.cyan[700], foregroundColor: isDark ? Colors.black : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("SCAN NOW", style: TextStyle(fontWeight: FontWeight.bold)))
      ])))
    ]));
  }

  Widget _buildMetricCard(BuildContext context, bool isDark, String title, String value, IconData icon, Color col) {
    return Expanded(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.05))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: col, size: 20), const SizedBox(height: 10), Text(title, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)), Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold))])));
  }
}