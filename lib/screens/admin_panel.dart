import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController _tipController = TextEditingController();

  Future<void> _updateDailyTip() async {
    if (_tipController.text.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('dailyTips').doc('today').set({
        'tip': _tipController.text,
        'date': FieldValue.serverTimestamp(),
        'updatedBy': 'Admin',
      });
      _tipController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tip Pushed to Dashboards!"), backgroundColor: Colors.cyanAccent),
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Check Theme Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ Dynamic Background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text("SKINSENTINEL AI | ADMIN PANEL",
            style: TextStyle(
                color: isDarkMode ? Colors.cyanAccent : Colors.cyan[800],
                fontWeight: FontWeight.bold,
                letterSpacing: 2
            )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.home_filled, color: isDarkMode ? Colors.cyanAccent : Colors.cyan[800]),
            onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildStatsRow(isDarkMode),
                  const SizedBox(height: 30),
                  _buildTipUpdaterCard(isDarkMode),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(flex: 3, child: _buildUserList(isDarkMode)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        int userCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Row(
          children: [
            _statTile(context, isDark, "TOTAL USERS", userCount.toString(), Icons.people_outline_rounded, Colors.blueAccent),
            const SizedBox(width: 15),
            _statTile(context, isDark, "SYSTEM STATUS", "ONLINE", Icons.sensors_rounded, Colors.greenAccent),
          ],
        );
      },
    );
  }

  Widget _statTile(BuildContext context, bool isDark, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          // ✅ Dynamic Card Color
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 45),
            const SizedBox(height: 15),
            Text(title, style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black45,
                fontSize: 12,
                fontWeight: FontWeight.bold
            )),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipUpdaterCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PUSH DAILY SKIN CARE ADVICE",
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              )),
          const SizedBox(height: 20),
          TextField(
            controller: _tipController,
            maxLines: 3,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Enter tip...",
              hintStyle: TextStyle(color: isDark ? Colors.white12 : Colors.black26),
              filled: true,
              fillColor: isDark ? Colors.black : Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _updateDailyTip,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.cyanAccent : Colors.cyan[700],
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("UPDATE USER DASHBOARDS", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUserList(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("REGISTERED PATIENTS",
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              )),
          const SizedBox(height: 10),
          Divider(color: isDark ? Colors.white10 : Colors.black),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var user = snapshot.data!.docs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person, color: isDark ? Colors.cyanAccent : Colors.cyan[700]),
                        title: Text(user['name'] ?? 'Anonymous',
                            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                        subtitle: Text(user['email'] ?? 'No Email',
                            style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}