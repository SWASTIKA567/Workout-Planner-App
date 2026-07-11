import 'package:flutter/material.dart';
import 'primary_focus_screen.dart';

class IntensityScreen extends StatefulWidget {
  final String gender;
  final int age;
  final int weight;
  final int height;
  final int targetweight;
  final String goal;
  final String fitnessLevel;

  const IntensityScreen({
    super.key,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.targetweight,
    required this.goal,
    required this.fitnessLevel,
  });

  @override
  State<IntensityScreen> createState() => _IntensityScreenState();
}

class _IntensityScreenState extends State<IntensityScreen> {
  String? selectedIntensity;

  final List<Map<String, dynamic>> intensityOptions = [
    {
      'label': 'Low',
      'value': 'low',
      'icon': Icons.directions_walk_rounded,
      'description': 'Gentle pace, easy on the body',
      'color': const Color(0xFF4CAF50),
    },
    {
      'label': 'Moderate',
      'value': 'moderate',
      'icon': Icons.directions_run_rounded,
      'description': 'Balanced effort, steady progress',
      'color': const Color(0xFFFF9800),
    },
    {
      'label': 'High',
      'value': 'high',
      'icon': Icons.flash_on_rounded,
      'description': 'Intense effort, maximum results',
      'color': const Color(0xFFF44336),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Intensity Preference",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "How hard do you want to push yourself?",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    ...intensityOptions.map((option) {
                      final isSelected = selectedIntensity == option['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIntensity = option['value'];
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (option['color'] as Color).withOpacity(0.12)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? (option['color'] as Color)
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: (option['color'] as Color)
                                          .withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (option['color'] as Color)
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  option['icon'] as IconData,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['label'] as String,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? (option['color'] as Color)
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      option['description'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: option['color'] as Color,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
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
                      onPressed: selectedIntensity != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrimaryFocusScreen(
                                    gender: widget.gender,
                                    age: widget.age,
                                    weight: widget.weight,
                                    height: widget.height,
                                    targetweight: widget.targetweight,
                                    goal: widget.goal,
                                    fitnessLevel: widget.fitnessLevel,
                                    intensityPreference: selectedIntensity!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004DFF),
                        disabledBackgroundColor: const Color(0xFFB1C8FF),
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
