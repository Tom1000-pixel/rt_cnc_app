import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://qwwtawqidgwiabenkuwk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3d3Rhd3FpZGd3aWFiZW5rdXdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1MzkzOTUsImV4cCI6MjA5ODExNTM5NX0.Q05_kZrzbL7n4FRlVsYOKyh7xrQ2ykPfnMFi6LiLGvg',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offset Analyzer Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B1C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5C451),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.precision_manufacturing, size: 80, color: Color(0xFFF5C451)),
            const SizedBox(height: 20),
            Text(
              'OFFSET ANALYZER',
              style: GoogleFonts.cinzel(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF5C451),
              ),
            ),
            const SizedBox(height: 5),
            const Text('PRO VERSION', style: TextStyle(letterSpacing: 4, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
