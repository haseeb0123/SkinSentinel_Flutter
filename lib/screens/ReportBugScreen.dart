import 'dart:ui';
import 'package:flutter/material.dart';

// ✅ Fixed: Linting errors hatane ke liye isay StatelessWidget banaya hai
class ReportBugScreen extends StatelessWidget {
  const ReportBugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReportBugView();
  }
}

class ReportBugView extends StatefulWidget {
  const ReportBugView({super.key});

  @override
  State<ReportBugView> createState() => _ReportBugViewState();
}

class _ReportBugViewState extends State<ReportBugView> {
  final TextEditingController _bugController = TextEditingController();

  @override
  void dispose() {
    _bugController.dispose();
    super.dispose();
  }

  // --- SUCCESS DIALOG (Adaptive) ---
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
                border: Border.all(
                    color: (isDark ? Colors.cyanAccent : Colors.cyan).withOpacity(0.2)
                ),
                boxShadow: isDark ? [] : [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      Icons.check_circle_outline_rounded,
                      color: isDark ? Colors.cyanAccent : Colors.cyan[700],
                      size: 70
                  ),
                  const SizedBox(height: 25),
                  Text("Thank You!",
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold
                      )),
                  const SizedBox(height: 12),
                  Text("Your report has been submitted. We'll fix it soon!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 14
                      )),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.cyanAccent : Colors.cyan[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        _bugController.clear();
                        Navigator.pop(dialogContext); // Close dialog
                        Navigator.pop(context); // Go back
                      },
                      child: Text("AWESOME",
                          style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold
                          )),
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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -50, right: -50, child: _buildOrb(200, Colors.redAccent.withOpacity(0.08))),
          Positioned(bottom: 100, left: -50, child: _buildOrb(250, Colors.cyanAccent.withOpacity(0.05))),

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
                        const SizedBox(height: 20),
                        const Center(child: Icon(Icons.bug_report_rounded, color: Colors.redAccent, size: 60)),
                        const SizedBox(height: 20),
                        Center(
                            child: Text("Found an issue?",
                                style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold
                                ))
                        ),
                        const SizedBox(height: 10),
                        Center(
                            child: Text("Help us improve SkinSentinel by describing the bug below.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: isDarkMode ? Colors.white38 : Colors.black45,
                                    fontSize: 13
                                ))
                        ),
                        const SizedBox(height: 40),
                        Text("Describe the issue",
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600
                            )),
                        const SizedBox(height: 15),

                        // Styled TextField (Adaptive)
                        TextField(
                          controller: _bugController,
                          maxLines: 6,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: "What went wrong? Tell us about the error...",
                            hintStyle: TextStyle(
                                color: isDarkMode ? Colors.white24 : Colors.black26,
                                fontSize: 14
                            ),
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF161925) : Colors.grey[100],
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.05))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)
                            ),
                            contentPadding: const EdgeInsets.all(25),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Submit Button
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.redAccent.withOpacity(isDarkMode ? 0.2 : 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5)
                              )
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              if (_bugController.text.trim().isNotEmpty) {
                                _showSuccessDialog(context, isDarkMode);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please describe the issue first.")),
                                );
                              }
                            },
                            child: const Text("SUBMIT REPORT",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 30),
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

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20),
              onPressed: () => Navigator.pop(context)
          ),
          const Spacer(),
          Text("Report a Bug",
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              )),
          const Spacer(),
          const SizedBox(width: 40),
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