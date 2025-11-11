import 'package:flutter/material.dart';
import 'Level_screen.dart';

class GoalScreen extends StatefulWidget {
  final String gender;
  final int age;
  final int weight;
  final int height;
  final int targetweight;

  const GoalScreen({
    super.key,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.targetweight,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String? selectedGoal;
  final List<String> goals = [
    'Flexibility',
    'Muscle Gain',
    'Weight Loss',
    'Endurance',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    " What's your goal?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    " This helps us Create your personalised plan",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
            const SizedBox(height: 90),

            // Goal Options
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(goals.length, (index) {
                  final goal = goals[index];
                  final isSelected = selectedGoal == goal;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGoal = goal;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 40,
                      ),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Color(0xFFE4E4E4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Color(0xFF004DFF) : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          goal,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
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
                        style: TextStyle(color: Colors.black),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: selectedGoal != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LevelScreen(
                                    gender: widget.gender,
                                    age: widget.age,
                                    weight: widget.weight,
                                    height: widget.height,
                                    targetweight: widget.targetweight,
                                    goal: selectedGoal!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004DFF),
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
                      label: const Text(
                        "Next",
                        style: TextStyle(color: Colors.black),
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
