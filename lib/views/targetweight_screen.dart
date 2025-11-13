import 'package:flutter/material.dart';
import 'goal_screen.dart';

class TargetWeightScreen extends StatefulWidget {
  final String gender;
  final int age;
  final int weight;
  final int height;

  const TargetWeightScreen({
    super.key,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
  });
  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen> {
  int? selectedTargetWeight;
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController();

  @override
  Widget build(BuildContext context) {
    print(
      "Gender : ${widget.gender}, Age: ${widget.age} ,Weight : ${widget.weight}, Height : ${widget.height}",
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "What Is Your Target Weight?",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "This helps us Create your personalised plan",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 60),

                // Profile Icon
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 60,
                  ),
                ),

                const SizedBox(height: 60),

                // Target Weight Selector
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 350,
                      child: ListWheelScrollView.useDelegate(
                        controller: _scrollController,
                        itemExtent: 60,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedTargetWeight = index + 40;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final targetWeight = index + 40;
                            final isSelected =
                                selectedTargetWeight == targetWeight;
                            return Center(
                              child: Text(
                                '$targetWeight kg',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: isSelected ? 32 : 24,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            );
                          },
                          childCount: 271, // Target weight from 30kg to 300kg
                        ),
                      ),
                    ),
                    Positioned(
                      top: 140,
                      child: Container(
                        width: 100,
                        height: 3,
                        color: Color(0xFF004DFF),
                      ),
                    ),
                    Positioned(
                      bottom: 140,
                      child: Container(
                        width: 100,
                        height: 3,
                        color: Color(0xFF004DFF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Bottom buttons
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
                        backgroundColor: const Color(0xFFB1C8FF),
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
                      onPressed: selectedTargetWeight != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GoalScreen(
                                    gender: widget.gender,
                                    age: widget.age,
                                    weight: widget.weight,
                                    height: widget.height,
                                    targetweight: selectedTargetWeight!,
                                  ),
                                ),
                              );
                            }
                          : null, // disabled if gender not selected
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004DFF),
                        disabledBackgroundColor: Color(0xFFB1C8FF),
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
