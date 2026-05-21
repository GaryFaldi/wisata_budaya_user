import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const WisataBudayaApp());
}

class WisataBudayaApp extends StatelessWidget {
  const WisataBudayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peta Wisata Budaya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5016),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}
