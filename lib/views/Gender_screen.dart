import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'age_screen.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;

  //Future<void> _logout(BuildContext context) async {
  /// await FirebaseAuth.instance.signOut();

  //if (context.mounted) {
  //  This clears the navigation stack and takes you to LoginScreen
  //  Navigator.pushAndRemoveUntil(
  // context,
  // MaterialPageRoute(builder: (_) => const LoginScreen()),
  // (route) => false,
  // );
  // }
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBE4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "Tell us about yourself !",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "To give you a better experience\n   by knowing your gender",
                    style: TextStyle(fontSize: 16, color: Color(0xFF1E1E1E)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // profile icon
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color.fromARGB(228, 248, 243, 243),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: const Color.fromARGB(255, 21, 21, 21),
                    ),
                  ),
                  const SizedBox(height: 70),

                  // Gender Buttons
                  Column(
                    children: [
                      genderButton("Female", "assets/female.svg"),
                      const SizedBox(height: 60),
                      genderButton("Male", "assets/male.svg"),
                    ],
                  ),
                  const SizedBox(height: 130),
                  //Bottom Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //  Skip to previous page
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        label: const Text(
                          "Back",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      //  Next to Age screen
                      ElevatedButton.icon(
                        onPressed: selectedGender != null
                            ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AgeScreen(gender: selectedGender!),
                                  ),
                                );
                              }
                            : null, // disabled if gender not selected
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004DFF),
                          disabledBackgroundColor: Color(0XFFB1C8FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        label: const Text(
                          "Next",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Gender Button
  Widget genderButton(String gender, String assetPath) {
    final bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF004DFF) : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(assetPath, height: 50, color: Colors.black),
            const SizedBox(height: 5),
            Text(
              gender,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
