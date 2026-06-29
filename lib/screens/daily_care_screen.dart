import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyCareScreen extends StatefulWidget {
  const DailyCareScreen({super.key});

  @override
  State<DailyCareScreen> createState() => _DailyCareScreenState();
}

class _DailyCareScreenState extends State<DailyCareScreen> {
  String _dailyTip = "Loading today's tip...";
  List<Map<String, dynamic>> _reminders = [];
  final TextEditingController _reminderController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchDailyTip();
    _fetchReminders();
  }

  Future<void> _fetchDailyTip() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('dailyTips').doc('today').get();
      if (doc.exists && doc.data() != null) {
        setState(() => _dailyTip = doc.data()!['tip'] ?? "Stay hydrated!");
      } else {
        setState(() => _dailyTip = "Remember to cleanse and moisturize daily!");
      }
    } catch (e) {
      setState(() => _dailyTip = "Failed to load tip. Check internet.");
    }
  }

  Future<void> _fetchReminders() async {
    if (user == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users').doc(user!.uid).collection('reminders')
          .orderBy('createdAt', descending: true).get();

      setState(() {
        _reminders = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      });
    } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> _addReminder() async {
    if (user == null || _reminderController.text.trim().isEmpty) return;
    final text = _reminderController.text.trim();
    _reminderController.clear();
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('users').doc(user!.uid).collection('reminders')
          .add({'text': text, 'isEnabled': true, 'createdAt': FieldValue.serverTimestamp()});
      setState(() {
        _reminders.insert(0, {'id': docRef.id, 'text': text, 'isEnabled': true, 'createdAt': Timestamp.now()});
      });
      FocusScope.of(context).unfocus();
    } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> _deleteReminder(String id) async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('reminders').doc(id).delete();
    _fetchReminders();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _buildOrb(200, Colors.cyanAccent.withOpacity(0.08))),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.spa_rounded, color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700]),
                      const SizedBox(width: 10),
                      Text("Skin Care Hub",
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                          )),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildTipCard(isDarkMode),

                        _reminders.isEmpty
                            ? Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: _buildEmptyState(isDarkMode),
                        )
                            : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reminders.length,
                          itemBuilder: (context, index) => _buildReminderTile(context, isDarkMode, _reminders[index]),
                        ),

                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Adaptive Input Box
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                ? MediaQuery.of(context).viewInsets.bottom + 10
                : 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                      color: isDarkMode ? Colors.black54 : Colors.black12,
                      blurRadius: 15,
                      offset: const Offset(0, 4)
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reminderController,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Add reminder...",
                        hintStyle: TextStyle(color: isDarkMode ? Colors.white30 : Colors.black38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _addReminder,
                    icon: Icon(Icons.add_circle, color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700], size: 30),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: isDark
                ? [Colors.cyanAccent.withOpacity(0.2), Colors.blueAccent.withOpacity(0.1)]
                : [Colors.cyan.withOpacity(0.1), Colors.blue.withOpacity(0.05)]
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.3) : Colors.cyan.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: isDark ? Colors.cyanAccent : Colors.cyan[700], size: 40),
          const SizedBox(width: 15),
          Expanded(
              child: Text(_dailyTip,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500))
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTile(BuildContext context, bool isDark, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03)),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        title: Text(data['text'],
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
          onPressed: () => _deleteReminder(data['id']),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
        child: Column(
          children: [
            Icon(Icons.notifications_none_rounded, size: 60, color: isDark ? Colors.white10 : Colors.black12),
            const SizedBox(height: 10),
            Text("No reminders yet!", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26)),
          ],
        )
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container()));
  }
}