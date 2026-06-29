import 'dart:ui';
import 'package:flutter/material.dart';

class ConsultScreen extends StatelessWidget {
  const ConsultScreen({super.key});

  // --- PREMIUM BLUR SUCCESS DIALOG (ADAPTIVE) ---
  void _showSuccessDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161925) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(isDark ? 0.2 : 0.5)),
                  boxShadow: [
                    if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
                  ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, color: isDark ? Colors.cyanAccent : Colors.cyan[700], size: 70),
                  const SizedBox(height: 25),
                  Text(
                    "Request Sent!",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Your appointment request for Dr. SkinSentinel AI has been submitted. You will receive a notification soon.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.cyanAccent : Colors.cyan[700],
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "GREAT",
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Theme Check
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(top: -50, left: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.08))),
          Positioned(bottom: 100, right: -50, child: _buildOrb(200, Colors.blueAccent.withOpacity(0.05))),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isDarkMode),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // --- DOCTOR PROFILE SECTION ---
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: Theme.of(context).cardColor,
                                  child: Icon(Icons.psychology_rounded, size: 60, color: isDarkMode ? Colors.cyanAccent : Colors.cyan[700]),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text("Dr. SkinSentinel AI",
                                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                              Text("Senior Dermatologist Specialist",
                                  style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black45, fontSize: 13)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),
                        Text("Clinic Location",
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),

                        // --- 📍 GOOGLE MAPS PREVIEW ---
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                            image: const DecorationImage(
                              image: NetworkImage('https://miro.medium.com/v2/resize:fit:1400/1*q69Z6pInO64sXN4V44qMFA.png'),
                              fit: BoxFit.cover,
                              opacity: 0.6,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 40),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
                                      child: const Text("City Medical Complex, Lahore",
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 10, right: 10,
                                child: CircleAvatar(
                                  backgroundColor: isDarkMode ? Colors.cyanAccent : Colors.cyan[700],
                                  radius: 20,
                                  child: Icon(Icons.directions_rounded, color: isDarkMode ? Colors.black : Colors.white, size: 20),
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        Text("Availability & Contact",
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),

                        _buildInfoTile(context, isDarkMode, Icons.phone_iphone_rounded, "+92 300 1234567"),
                        _buildInfoTile(context, isDarkMode, Icons.schedule_rounded, "Mon - Fri, 09:00 AM - 05:00 PM"),

                        const SizedBox(height: 30),

                        // --- BOOK BUTTON ---
                        Container(
                          width: double.infinity,
                          height: 60,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ElevatedButton(
                            onPressed: () => _showSuccessDialog(context, isDarkMode),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? Colors.cyanAccent : Colors.cyan[700],
                              foregroundColor: isDarkMode ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 10,
                              shadowColor: (isDarkMode ? Colors.cyanAccent : Colors.cyan).withOpacity(0.3),
                            ),
                            child: const Text("CONFIRM APPOINTMENT",
                                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
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

  // --- UI HELPERS ---

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text("Consult Specialist",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, bool isDark, IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.cyanAccent : Colors.cyan[700], size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14))),
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