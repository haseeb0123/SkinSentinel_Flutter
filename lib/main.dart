import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added
import 'firebase_options.dart';

// Screens imports
import 'screens/dashboard.dart';
import 'screens/splash_screen.dart';
import 'screens/admin_panel.dart';

// Conditional Import
import 'screens/scanner_web.dart' if (dart.library.io) 'screens/scanner_screen.dart';

// Global notifier
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Shared Preferences se theme load karna
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? true; // Default dark rahega agar pehli bar open ho
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SkinSentinel());
}

class SkinSentinel extends StatelessWidget {
  const SkinSentinel({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Skin Sentinel',
          themeMode: currentMode,

          // 🟡 LIGHT THEME CONFIG
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.cyan,
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            cardColor: Colors.white,
            canvasColor: Colors.white,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF5F7FA),
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black87),
            ),
          ),

          // 🔵 DARK THEME CONFIG
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.cyanAccent,
            scaffoldBackgroundColor: const Color(0xFF040508),
            cardColor: const Color(0xFF161925),
            canvasColor: const Color(0xFF161925),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF040508),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
          ),

          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/admin': (context) => const AdminPanel(),
            '/scanner': (context) => const ScannerScreen(),
          },
        );
      },
    );
  }
}