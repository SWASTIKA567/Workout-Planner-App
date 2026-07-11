import 'package:flutter/material.dart';
import 'equipment_screen.dart';

class PrimaryFocusScreen extends StatefulWidget {
  final String gender;
  final int age;
  final int weight;
  final int height;
  final int targetweight;
  final String goal;
  final String fitnessLevel;
  final String intensityPreference;

  const PrimaryFocusScreen({
    super.key,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.targetweight,
    required this.goal,
    required this.fitnessLevel,
    required this.intensityPreference,
  });

  @override
  State<PrimaryFocusScreen> createState() => _PrimaryFocusScreenState();
}

class _PrimaryFocusScreenState extends State<PrimaryFocusScreen> {
  String? selectedFocus;

  final List<Map<String, dynamic>> focusOptions = [
    {
      'label': 'Core Strength',
      'value': 'core_strength',
      'icon': Icons.fitness_center_rounded,
      'color': const Color(0xFF6C63FF),
    },
    {
      'label': 'Mind-Body Relaxation',
      'value': 'mind_body_relaxation',
      'icon': Icons.self_improvement_rounded,
      'color': const Color(0xFF4CAF50),
    },
    {
      'label': 'Muscle Building',
      'value': 'muscle_building',
      'icon': Icons.sports_gymnastics_rounded,
      'color': const Color(0xFFE91E63),
    },
    {
      'label': 'Strength & Toning',
      'value': 'strength_toning',
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFFFF5722),
    },
    {
      'label': 'Cardio Endurance',
      'value': 'cardio_endurance',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFF44336),
    },
    {
      'label': 'Stamina Building',
      'value': 'stamina_building',
      'icon': Icons.directions_run_rounded,
      'color': const Color(0xFFFF9800),
    },
    {
      'label': 'Fat Burning',
      'value': 'fat_burning',
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFFF6D00),
    },
    {
      'label': 'Calorie Burn Intensity',
      'value': 'calorie_burn_intensity',
      'icon': Icons.speed_rounded,
      'color': const Color(0xFFF44336),
    },
    {
      'label': 'Overall Toning',
      'value': 'overall_toning',
      'icon': Icons.accessibility_new_rounded,
      'color': const Color(0xFF9C27B0),
    },
    {
      'label': 'General Wellness',
      'value': 'general_wellness',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFF009688),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Primary Focus",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "What do you want to focus on most?",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.3,
                        ),
                    itemCount: focusOptions.length,
                    itemBuilder: (context, index) {
                      final option = focusOptions[index];
                      final isSelected = selectedFocus == option['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFocus = option['value'];
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
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
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                option['icon'] as IconData,
                                color: isSelected
                                    ? (option['color'] as Color)
                                    : Colors.grey.shade500,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                option['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? (option['color'] as Color)
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80),
              ],
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
                      onPressed: selectedFocus != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EquipmentScreen(
                                    gender: widget.gender,
                                    age: widget.age,
                                    weight: widget.weight,
                                    height: widget.height,
                                    targetweight: widget.targetweight,
                                    goal: widget.goal,
                                    fitnessLevel: widget.fitnessLevel,
                                    intensityPreference:
                                        widget.intensityPreference,
                                    primaryFocus: selectedFocus!,
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
