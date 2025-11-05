import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout_planner/views/Gender_screen.dart';
import 'package:workout_planner/views/home_screen.dart';
import '../login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Delay until after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      if (user != null) {
        // ✅ Navigate safely after build
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint("Error in SplashScreen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'assets/bg1.jpg', // background image
          fit: BoxFit.cover, // full screen cover
        ),
      ),
    );
  }
}
