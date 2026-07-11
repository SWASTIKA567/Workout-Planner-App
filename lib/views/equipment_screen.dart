import 'package:flutter/material.dart';
import '../../controllers/input_controller.dart';
import '../../models/user_input_model.dart';
import 'home_screen.dart';

class EquipmentScreen extends StatefulWidget {
  final String gender;
  final int age;
  final int weight;
  final int height;
  final int targetweight;
  final String goal;
  final String fitnessLevel;
  final String intensityPreference;
  final String primaryFocus;

  const EquipmentScreen({
    super.key,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.targetweight,
    required this.goal,
    required this.fitnessLevel,
    required this.intensityPreference,
    required this.primaryFocus,
  });

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  String? selectedEquipment;
  bool isLoading = false;

  final List<Map<String, dynamic>> equipmentOptions = [
    {
      'label': 'Bodyweight Only',
      'value': 'bodyweight_only',
      'icon': Icons.accessibility_new_rounded,
      'description': 'No equipment needed',
      'color': const Color(0xFF4CAF50),
    },
    {
      'label': 'Dumbbells at Home',
      'value': 'dumbbells_home',
      'icon': Icons.fitness_center_rounded,
      'description': 'Basic home weights',
      'color': const Color(0xFF2196F3),
    },
    {
      'label': 'Kettlebell at Home',
      'value': 'kettlebell_home',
      'icon': Icons.sports_handball_rounded,
      'description': 'Kettlebell exercises',
      'color': const Color(0xFF9C27B0),
    },
    {
      'label': 'Resistance Bands',
      'value': 'resistance_bands',
      'icon': Icons.loop_rounded,
      'description': 'Elastic band training',
      'color': const Color(0xFFFF9800),
    },
    {
      'label': 'Full Gym',
      'value': 'full_gym',
      'icon': Icons.apartment_rounded,
      'description': 'Full gym equipment access',
      'color': const Color(0xFF6C63FF),
    },
    {
      'label': 'Cardio Machine',
      'value': 'cardio_machine',
      'icon': Icons.directions_bike_rounded,
      'description': 'Treadmill, bike, elliptical',
      'color': const Color(0xFFF44336),
    },
    {
      'label': 'Yoga Mat',
      'value': 'yoga_mat',
      'icon': Icons.self_improvement_rounded,
      'description': 'Mat exercises & stretching',
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
                  "Equipment Access",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "What equipment do you have available?",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: equipmentOptions.length,
                    itemBuilder: (context, index) {
                      final option = equipmentOptions[index];
                      final isSelected =
                          selectedEquipment == option['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedEquipment = option['value'];
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(vertical: 7),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (option['color'] as Color).withOpacity(0.10)
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
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (option['color'] as Color)
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  option['icon'] as IconData,
                                  color: Colors.white,
                                  size: 26,
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? (option['color'] as Color)
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
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
                    },
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),

            // Navigation Buttons
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
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
                      onPressed: selectedEquipment != null && !isLoading
                          ? () async {
                              setState(() => isLoading = true);

                              // Map display goal to API value
                              final goalMap = {
                                'Flexibility': 'flexibility',
                                'Muscle Gain': 'muscle_gain',
                                'Weight Loss': 'weight_loss',
                                'Endurance': 'endurance',
                                'General Fitness': 'general_fitness',
                              };

                              final input = UserInputModel(
                                heightCm: widget.height,
                                targetWeight: widget.targetweight,
                                goal: goalMap[widget.goal] ?? widget.goal,
                                gender: widget.gender.toLowerCase(),
                                age: widget.age,
                                weightKg: widget.weight,
                                fitnessLevel: widget.fitnessLevel.toLowerCase(),
                                intensityPreference: widget.intensityPreference,
                                primaryFocus: widget.primaryFocus,
                                equipmentAccess: selectedEquipment!,
                              );

                              final controller = InputController();
                              await controller.submitInputs(input);

                              setState(() => isLoading = false);

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              }
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
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_rounded, size: 18),
                      label: isLoading
                          ? const Text(
                              "Submitting...",
                              style: TextStyle(color: Colors.white),
                            )
                          : const Text(
                              "Finish",
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
