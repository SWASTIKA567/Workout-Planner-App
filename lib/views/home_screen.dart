import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:workout_planner/views/library_screen.dart';
import 'dart:convert';
import '/controllers/api2_controller.dart';
import 'choice_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? workoutType;
  String? fitnessLevel;
  double? bmi;
  bool isLoading = true;
  int? selectedDayIndex;
  int? loadingDayIndex;
  final Map<String, Map<String, String>> workoutData = {
    "Cardio": {
      "image": "assets/girl.jpeg",
      "description":
          "Cardio workouts improve heart health and increase stamina.\n"
          "They help burn calories efficiently.\n"
          "Boost endurance and energy levels.\n"
          "Includes running, cycling, and skipping.",
    },

    "Strength": {
      "image": "assets/images/strength.png",
      "description":
          "Strength training builds muscle and power.\n"
          "Improves metabolism and body tone.\n"
          "Enhances bone density and posture.\n"
          "Includes weight lifting and resistance training.",
    },

    "HIIT": {
      "image": "assets/images/hiit.png",
      "description":
          "HIIT stands for High-Intensity Interval Training.\n"
          "Burns maximum calories in short time.\n"
          "Improves cardiovascular performance.\n"
          "Includes fast bursts of intense exercises.",
    },

    "Yoga": {
      "image": "assets/images/yoga.png",
      "description":
          "Yoga improves flexibility and balance.\n"
          "Reduces stress and increases mindfulness.\n"
          "Enhances breathing control and posture.\n"
          "Includes stretching and relaxation poses.",
    },
  };

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final Api2Controller api2controller = Get.put(Api2Controller());

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchWorkoutData();
  }

  Future<void> fetchWorkoutData() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        showSnackBar("No user logged in. Please log in again.");
        setState(() => isLoading = false);
        return;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          workoutType = doc['workout_type'];
          fitnessLevel = doc['inputs']['fitness_level'];
          bmi = (data['bmi'] as num?)?.toDouble();
          isLoading = false;
        });
        log("Fetched data -> Type: $workoutType | Level : $fitnessLevel");

        showSnackBar("Workout data fetched successfully ");
      } else {
        setState(() => isLoading = false);
        showSnackBar("No workout data found. Please complete setup.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      showSnackBar("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 227, 248),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Welcome back, ",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Let's have a productive workout day!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 30),

              Container(
                padding: EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.65,
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Workout type is",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF7B4FA3),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  workoutType != null
                                      ? workoutType![0].toUpperCase() +
                                          workoutType!.substring(1)
                                      : "Not available yet",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF7B4FA3),
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                if (workoutType != null &&
                                    workoutData.containsKey(
                                      workoutType![0].toUpperCase() +
                                          workoutType!.substring(1),
                                    ))
                                  Image.asset(
                                    workoutData[workoutType![0].toUpperCase() +
                                        workoutType!.substring(1)]!["image"]!,
                                    height: 140,
                                    fit: BoxFit.contain,
                                  ),

                                const SizedBox(height: 12),

                                if (workoutType != null &&
                                    workoutData.containsKey(
                                      workoutType![0].toUpperCase() +
                                          workoutType!.substring(1),
                                    ))
                                  Text(
                                    workoutData[workoutType![0].toUpperCase() +
                                        workoutType!.substring(1)]!["description"]!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.6,
                                    ),
                                  ),

                                if (workoutType == null)
                                  const Text(
                                    "Please complete the setup to see your workout plan.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      height: 1.6,
                                    ),
                                  ),

                                // ── BMI Section ──
                                if (bmi != null) ...[  
                                  const SizedBox(height: 20),
                                  const Divider(thickness: 1),
                                  const SizedBox(height: 12),
                                  _buildBmiSection(),
                                ],
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF7B4BFF),
            unselectedItemColor: Colors.grey.shade500,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == _selectedIndex) return;

              setState(() {
                _selectedIndex = index;
              });

              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ChoiceScreen()),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu_rounded),
                label: "Diet",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBmiSection() {
    if (bmi == null) return const SizedBox.shrink();

    String category;
    Color categoryColor;
    String emoji;

    if (bmi! < 18.5) {
      category = 'Underweight';
      categoryColor = const Color(0xFF2196F3);
      emoji = '⚖️';
    } else if (bmi! < 25.0) {
      category = 'Normal';
      categoryColor = const Color(0xFF4CAF50);
      emoji = '✅';
    } else if (bmi! < 30.0) {
      category = 'Overweight';
      categoryColor = const Color(0xFFFF9800);
      emoji = '⚠️';
    } else {
      category = 'Obese';
      categoryColor = const Color(0xFFF44336);
      emoji = '🔴';
    }

    // Clamp BMI for progress bar: 10 to 40 range
    final double progress = ((bmi! - 10) / 30).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Your BMI",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7B4FA3),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                bmi!.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'kg/m²',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: categoryColor.withOpacity(0.4)),
            ),
            child: Text(
              '$emoji  $category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('10', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('18.5', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('25', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('30', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('40+', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
