import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_planner/views/Gender_screen.dart';
import 'home_screen.dart';
import 'package:workout_planner/login_screen.dart';

class SetupChecker extends StatefulWidget {
  const SetupChecker({super.key});

  @override
  State<SetupChecker> createState() => _SetupCheckerState();
}

class _SetupCheckerState extends State<SetupChecker> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final isSetupComplete =
          doc.exists && doc.data()?['isSetupComplete'] == true;

      if (isSetupComplete) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GenderScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error checking setup: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : const Text("Checking setup..."),
      ),
    );
  }
}
