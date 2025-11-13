import 'package:flutter/material.dart';
import 'package:workout_planner/views/Gender_screen.dart';
import 'weight_screen.dart';

class AgeScreen extends StatefulWidget {
  final String gender;
  const AgeScreen({super.key, required this.gender});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  int? selectedAge;
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController();

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
                const Text(
                  "How old are you?",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "    To provide you with a better\n experience by knowing your age",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 60),

                // Profile Icon
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF1E1E1E),
                    size: 60,
                  ),
                ),

                const SizedBox(height: 60),

                // Age Selector
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 350,
                      child: ListWheelScrollView.useDelegate(
                        controller: _scrollController,
                        itemExtent: 60,
                        diameterRatio: 2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedAge = index + 12;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final age = index + 12;
                            final isSelected = selectedAge == age;
                            return Center(
                              child: Text(
                                '$age',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: isSelected ? 38 : 36,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                          childCount: 100,
                        ),
                      ),
                    ),
                    // lines between selected age
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GenderScreen(),
                          ),
                        );
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
                      onPressed: selectedAge != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WeightScreen(
                                    age: selectedAge!,
                                    gender: widget.gender,
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
