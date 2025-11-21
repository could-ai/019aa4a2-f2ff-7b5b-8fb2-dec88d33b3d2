import 'package:flutter/material.dart';
import 'package:couldai_user_app/screens/boombox_screen.dart';

void main() {
  runApp(const SonyBoomboxApp());
}

class SonyBoomboxApp extends StatelessWidget {
  const SonyBoomboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sony Boombox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53935), // Sony Red
          secondary: Color(0xFF424242), // Dark Grey
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
        fontFamily: 'Courier', // Monospace for a retro feel
      ),
      // Routing safety: Ensure default route is registered
      initialRoute: '/',
      routes: {
        '/': (context) => const BoomboxScreen(),
      },
    );
  }
}
