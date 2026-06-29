import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Added url_launcher
import 'consult_screen.dart';

class AhmadDetailScreen extends StatelessWidget {
  final String resultName;
  final String date;
  final String confidence;
  final String? imageUrl;

  const AhmadDetailScreen({
    super.key,
    this.resultName = "Issue Detected",
    this.date = "Recent",
    this.confidence = "0%",
    this.imageUrl,
  });

  // ✅ Google Maps Clinic Search Function
  Future<void> _openNearbyClinics() async {
    const String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=Skin+Clinics+Dermatologist";
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    } catch (e) {
      debugPrint("Error opening maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Check Theme Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- 🧠 RISK LOGIC ---
    double score = double.tryParse(confidence.replaceAll('%', '')) ?? 0.0;

    String riskLevel;
    Color riskColor;

    if (score >= 90) {
      riskLevel = "High Risk";
      riskColor = Colors.redAccent;
    } else if (score >= 70) {
      riskLevel = "Moderate";
      riskColor = Colors.orangeAccent;
    } else {
      riskLevel = "Low Risk";
      riskColor = Colors.yellowAccent;
    }

    return Scaffold(
      // ✅ Dynamic Background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _buildOrb(250, riskColor.withOpacity(0.08))),
          Positioned(bottom: 100, left: -50, child: _buildOrb(200, riskColor.withOpacity(0.05))),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isDarkMode),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // --- 📸 DYNAMIC SCAN IMAGE ---
                        _buildScanImage(context, isDarkMode, imageUrl),

                        const SizedBox(height: 20),

                        // --- RISK STATUS CARD (DYNAMIC) ---
                        _buildRiskStatusCard(resultName, riskLevel, riskColor),

                        const SizedBox(height: 35),

                        Text("Technical Overview",
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            )),
                        const SizedBox(height: 15),

                        _buildPremiumDetailTile(context, isDarkMode, "Confidence Score", confidence, Icons.analytics_outlined, Colors.cyanAccent),
                        _buildPremiumDetailTile(context, isDarkMode, "Detection Date", date, Icons.calendar_today_rounded, Colors.orangeAccent),
                        _buildPremiumDetailTile(context, isDarkMode, "Severity Level", riskLevel, Icons.speed_rounded, riskColor),

                        const SizedBox(height: 35),

                        Text("Required Action",
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            )),
                        const SizedBox(height: 15),

                        _buildConsultationCard(context, isDarkMode),

                        const SizedBox(height: 15),

                        // --- 🏥 MAP INTEGRATION FOR AHMAD SCREEN ---
                        _buildNearbyClinicsCard(context, isDarkMode),

                        const SizedBox(height: 40),

                        Center(
                          child: Text(
                            "Please do not self-medicate. Consult the specialist above.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26, fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 50),
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

  Widget _buildScanImage(BuildContext context, bool isDark, String? url) {
    return Container(
      height: 200, width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
        color: Theme.of(context).cardColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: (url != null && url.isNotEmpty)
            ? Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.broken_image_rounded, color: isDark ? Colors.white24 : Colors.black12, size: 50),
          ),
        )
            : Center(
          child: Icon(Icons.image_not_supported_rounded, color: isDark ? Colors.white24 : Colors.black12, size: 50),
        ),
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
          Text("Detailed Report",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRiskStatusCard(String disease, String level, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, size: 45, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(level,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(disease,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildPremiumDetailTile(BuildContext context, bool isDark, String title, String val, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 15),
          Text(title, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
          const Spacer(),
          Text(val, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.cyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultScreen())),
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.medical_services_rounded, color: Colors.cyanAccent, size: 28),
        ),
        title: Text("Consult Specialist",
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("Talk to our AI Doctor / Specialist",
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 16),
      ),
    );
  }

  Widget _buildNearbyClinicsCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14222A) : Colors.cyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: _openNearbyClinics, // ✅ Triggers Google Maps Search
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.location_on_rounded, color: Colors.cyanAccent, size: 28),
        ),
        title: Text("Find Nearby Clinics",
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("Search local dermatologists on Google Maps",
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 16),
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