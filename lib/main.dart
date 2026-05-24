import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'utils/session_service.dart';

void main() {
  runApp(const WisataBudayaApp());
}

class WisataBudayaApp extends StatelessWidget {
  const WisataBudayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nusantara Trail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5016),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}

/// Cek session saat app dibuka — arahkan ke Login atau Dashboard
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final loggedIn = await SessionService.isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            loggedIn ? const DashboardScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Splash sederhana saat cek session
    return const Scaffold(
      backgroundColor: Color(0xFF2D5016),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.temple_buddhist_rounded,
              color: Color(0xFFD4A853),
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Nusantara Trail',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              color: Color(0xFFD4A853),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
