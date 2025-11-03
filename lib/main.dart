import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workout_planner/views/Gender_screen.dart';
import 'package:workout_planner/views/set-up_checker.dart';
import 'views/splash_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WORKOUT APP',
      debugShowCheckedModeBanner: false,

      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),

        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const SetupChecker(),
      },
    );
  }
}
