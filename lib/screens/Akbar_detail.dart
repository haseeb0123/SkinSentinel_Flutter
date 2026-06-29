import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Added url_launcher

class AkbarDetailScreen extends StatelessWidget {
  final String resultName;
  final String date;
  final String confidence;
  final String? imageUrl;

  const AkbarDetailScreen({
    super.key,
    this.resultName = "Normal/Healthy",
    this.date = "Recent Analysis",
    this.confidence = "90%",
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
    // ✅ Theme Check
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ Dynamic Background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(top: -50, left: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.1))),
          Positioned(bottom: 100, right: -50, child: _buildOrb(200, Colors.blueAccent.withOpacity(0.05))),

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

                        // --- MAIN STATUS CARD ---
                        _buildMainStatusCard(context, isDarkMode, resultName),

                        const SizedBox(height: 30),

                        Text("Analysis Details",
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            )),
                        const SizedBox(height: 15),
                        _buildMetricTile(context, isDarkMode, "Analysis Date", date, isDarkMode ? Colors.white : Colors.black87),
                        _buildMetricTile(context, isDarkMode, "AI Confidence", confidence, isDarkMode ? Colors.cyanAccent : Colors.cyan[700]!),
                        _buildMetricTile(context, isDarkMode, "Scan Source", "Mobile Camera", Colors.blueAccent),

                        const SizedBox(height: 30),

                        // --- AI INSIGHTS ---
                        Row(
                          children: [
                            Icon(Icons.psychology_outlined, color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700], size: 24),
                            const SizedBox(width: 10),
                            Text("AI Observations",
                                style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                )),
                          ],
                        ),
                        const SizedBox(height: 15),

                        _buildPremiumInsightItem(
                          context,
                          isDarkMode,
                          resultName.toLowerCase().contains("normal") || resultName.toLowerCase().contains("healthy")
                              ? "Excellent! No suspicious patterns or skin issues were detected."
                              : "The analysis shows patterns typical of $resultName.",
                          Icons.verified_user_outlined,
                        ),
                        _buildPremiumInsightItem(
                          context,
                          isDarkMode,
                          "The AI model processed this scan with $confidence accuracy.",
                          Icons.analytics_outlined,
                        ),

                        const SizedBox(height: 30),

                        // --- 🏥 NEARBY CLINICS CARD FOR AKBAR ---
                        _buildNearbyClinicsCard(context, isDarkMode),

                        const SizedBox(height: 20),
                        _buildTipCard(isDarkMode),
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
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.1) : Colors.cyan.withOpacity(0.2)),
        color: Theme.of(context).cardColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
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

  Widget _buildMainStatusCard(BuildContext context, bool isDark, String title) {
    bool isHealthy = title.toLowerCase().contains("normal") || title.toLowerCase().contains("healthy");
    Color statusColor = isHealthy ? (isDark ? Colors.cyanAccent : Colors.cyan[700]!) : Colors.orangeAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: statusColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(isDark ? 0.05 : 0.1),
              blurRadius: 20,
              spreadRadius: 1,
            )
          ]
      ),
      child: Column(
        children: [
          Icon(
              isHealthy ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: statusColor,
              size: 60
          ),
          const SizedBox(height: 15),
          Text(title,
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(isHealthy ? "STATUS: CLEAR" : "STATUS: REVIEW NEEDED",
              style: TextStyle(
                  color: isHealthy ? (isDark ? Colors.greenAccent : Colors.green[700]) : Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2
              )),
        ],
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, bool isDark, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPremiumInsightItem(BuildContext context, bool isDark, String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.cyanAccent : Colors.cyan[700], size: 22),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildNearbyClinicsCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14222A) : Colors.cyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: _openNearbyClinics, // ✅ Triggers Google Maps Search
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Icon(Icons.map_rounded, color: isDark ? Colors.cyanAccent : Colors.cyan[700], size: 28),
        ),
        title: Text("Find Nearby Clinics",
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("Locate professional dermatologists near you",
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 16),
      ),
    );
  }

  Widget _buildTipCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: isDark
                ? [Colors.cyanAccent.withOpacity(0.1), Colors.blueAccent.withOpacity(0.05)]
                : [Colors.cyan.withOpacity(0.1), Colors.blue.withOpacity(0.05)]
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.1) : Colors.cyan.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: isDark ? Colors.cyanAccent : Colors.cyan[700], size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text("This analysis is AI-generated and should be used for informational purposes only. Consult a professional for a formal diagnosis.",
                style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 11, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70), child: Container()),
    );
  }
}