import 'package:flutter/material.dart';
import '../../controllers/input_controller.dart';
import '../../models/user_input_model.dart';
import 'home_screen.dart';

class LevelScreen extends StatefulWidget {
  final String gender;
  final int age;
  final int weight;
  final int height;
  final int targetweight;
  final String goal;

  const LevelScreen({
    super.key,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.targetweight,
    required this.goal,
  });

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  String? selectedLevel;
  bool isLoading = false;

  final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                SizedBox(height: 40),
                Center(
                  child: Text(
                    "What is your Fitness Level?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    "This helps us create your personalised plan",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),

            // levels section
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(levels.length, (index) {
                  final level = levels[index];
                  final isSelected = selectedLevel == level;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLevel = level;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 40,
                      ),
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF9C7B44)
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          level,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[400],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // bottom buttons
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C7B44),
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
                    ElevatedButton.icon(
                      onPressed: selectedLevel != null
                          ? () async {
                              setState(() => isLoading = true);

                              // Create input model
                              final input = UserInputModel(
                                heightCm: widget.height,
                                targetWeight: widget.targetweight,
                                goal: widget.goal,
                                gender: widget.gender,
                                age: widget.age,
                                weightKg: widget.weight,
                                fitnessLevel: selectedLevel!,
                              );

                              //  Call API
                              final controller = InputController();

                              await controller.submitInputs(input);

                              setState(() => isLoading = false);

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C7B44),
                        disabledBackgroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Next",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
