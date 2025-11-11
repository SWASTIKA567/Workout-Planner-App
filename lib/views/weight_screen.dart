import 'package:flutter/material.dart';
import 'height_screen.dart';

class WeightScreen extends StatefulWidget {
  final String gender;
  final int age;
  const WeightScreen({super.key, required this.gender, required this.age});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  int? selectedWeight;
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController();

  @override
  Widget build(BuildContext context) {
    print('Gender: ${widget.gender}, Age : ${widget.age}');
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
                  "What Is Your Weight?",
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
                            selectedWeight = index + 30;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final weight = index + 30;
                            final isSelected = selectedWeight == weight;
                            return Center(
                              child: Text(
                                '$weight kg',
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

                    ElevatedButton.icon(
                      onPressed: selectedWeight != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HeightScreen(
                                    gender: widget.gender,
                                    age: widget.age,
                                    weight: selectedWeight!,
                                  ),
                                ),
                              );
                            }
                          : null, // disabled if gender not selected
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
