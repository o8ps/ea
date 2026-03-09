import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/discord_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await DiscordService().loadPrefs();
  runApp(const EaApp());
}

class EaApp extends StatelessWidget {
  const EaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ea',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D10),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF0D0D10),
          primary: Colors.white,
          secondary: Color(0xFF929292),
        ),
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D10),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 13,
            letterSpacing: 4,
            fontFamily: 'monospace',
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2A2E)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2A2E)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF555555)),
          ),
          hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 13),
          labelStyle: const TextStyle(color: Color(0xFF929292), fontSize: 11, letterSpacing: 1.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E1E22),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            textStyle: const TextStyle(fontSize: 12, letterSpacing: 1, fontFamily: 'monospace'),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
