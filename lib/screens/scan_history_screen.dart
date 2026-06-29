import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'result_screen.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScanHistoryView();
  }
}

class ScanHistoryView extends StatefulWidget {
  const ScanHistoryView({super.key});

  @override
  State<ScanHistoryView> createState() => _ScanHistoryViewState();
}

class _ScanHistoryViewState extends State<ScanHistoryView> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -50, right: -50, child: _buildOrb(200, Colors.cyanAccent.withOpacity(0.08))),
          Positioned(bottom: 100, left: -50, child: _buildOrb(250, Colors.blueAccent.withOpacity(0.05))),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isDarkMode),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('scans')
                        .where('userId', isEqualTo: user?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error loading history", style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54)));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState(isDarkMode);
                      }

                      // Professional Sorting logic
                      List<QueryDocumentSnapshot> docs = snapshot.data!.docs.toList();
                      docs.sort((a, b) {
                        var dataA = a.data() as Map<String, dynamic>;
                        var dataB = b.data() as Map<String, dynamic>;
                        var timeA = dataA['timestamp'] ?? dataA['createdAt'] ?? Timestamp.now();
                        var timeB = dataB['timestamp'] ?? dataB['createdAt'] ?? Timestamp.now();
                        return (timeB as Timestamp).compareTo(timeA as Timestamp);
                      });

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var doc = docs[index];
                          var scan = doc.data() as Map<String, dynamic>;

                          // Mark it so ResultScreen doesn't resave it
                          scan['isFromHistory'] = true;

                          var rawDate = scan['timestamp'] ?? scan['createdAt'];
                          DateTime date = rawDate != null ? (rawDate as Timestamp).toDate() : DateTime.now();
                          String formattedDate = DateFormat('dd MMM, yyyy').format(date);
                          String formattedTime = DateFormat('hh:mm a').format(date);

                          return InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ResultScreen(scanData: scan))
                            ),
                            child: _buildScanCard(scan, formattedDate, formattedTime, isDarkMode),
                          );
                        },
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
          Text("Scan History",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildScanCard(Map<String, dynamic> scan, String date, String time, bool isDark) {
    var rawAccuracy = scan['accuracy'];
    double accuracyValue = 0.0;

    if (rawAccuracy is String) {
      accuracyValue = double.tryParse(rawAccuracy) ?? 0.0;
    } else if (rawAccuracy is num) {
      accuracyValue = rawAccuracy.toDouble();
    }

    if (accuracyValue > 0 && accuracyValue <= 1.0) {
      accuracyValue *= 100;
    }

    Color statusColor = accuracyValue > 75 ? Colors.greenAccent : Colors.orangeAccent;
    String imageUrl = scan['imageUrl'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161925) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 55, height: 55,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: isDark ? Colors.white10 : Colors.grey[200]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white24))
                  : Icon(Icons.document_scanner_rounded, color: isDark ? Colors.cyanAccent : Colors.cyan[700]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan['label'] ?? scan['result'] ?? "Skin Analysis",
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8, runSpacing: 4,
                  children: [
                    _buildIconText(Icons.calendar_today_rounded, date, isDark),
                    _buildIconText(Icons.access_time_rounded, time, isDark),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${accuracyValue.toStringAsFixed(1)}%",
                  style: TextStyle(color: statusColor, fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Accuracy", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10)),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, color: isDark ? Colors.white10 : Colors.black12, size: 80),
          const SizedBox(height: 20),
          Text("No History Yet",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
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