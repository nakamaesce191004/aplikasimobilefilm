import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Changed to flutter_riverpod
import 'main_screen.dart';

void main() {
  // Ensure status bar style matches our dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilmKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF005D), // Signature Red/Pink
        scaffoldBackgroundColor: const Color(0xFF141414), // Premium Dark Grey
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF005D),
          secondary: Color(0xFF00E5FF), // Cyan accent
          surface: Color(0xFF1F1F1F),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1F1F1F),
          selectedItemColor: Color(0xFFFF005D),
          unselectedItemColor: Colors.grey,
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.inter(color: Colors.white),
          bodyMedium: GoogleFonts.inter(color: Colors.white70),
          titleLarge: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: GoogleFonts.poppins(
             color: Colors.white,
             fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
