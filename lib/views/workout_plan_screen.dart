import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/api2_controller.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> with TickerProviderStateMixin {
  final Api2Controller controller = Get.put(Api2Controller());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> dayNamesShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final List<String> dayNamesFull = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  // Track completed exercises per day
  final Set<String> _completedExercises = {};
  // Track expanded exercise cards
  final Set<String> _expandedExercises = {};

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      controller.fetchWeeklyExercisePlan(user.uid);
    }
  }

  void _toggleExerciseCompleted(String key) {
    setState(() {
      if (_completedExercises.contains(key)) {
        _completedExercises.remove(key);
      } else {
        _completedExercises.add(key);
      }
    });
  }

  void _toggleExerciseExpanded(String key) {
    setState(() {
      if (_expandedExercises.contains(key)) {
        _expandedExercises.remove(key);
      } else {
        _expandedExercises.add(key);
      }
    });
  }

  void _showExerciseDetailModal(
    BuildContext context,
    Map<String, dynamic> exercise,
    int index,
    Color themeColor,
    String focus,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ExerciseDetailModal(
          exercise: exercise,
          index: index,
          themeColor: themeColor,
          focus: focus,
        );
      },
    );
  }

  IconData _getExerciseIcon(String name, String focus) {
    final lowerName = name.toLowerCase();
    final lowerFocus = focus.toLowerCase();

    if (lowerName.contains('press') || lowerName.contains('chest') || lowerName.contains('push-up')) {
      return Icons.fitness_center_rounded;
    } else if (lowerName.contains('row') || lowerName.contains('pull') || lowerName.contains('deadlift')) {
      return Icons.accessibility_new_rounded;
    } else if (lowerName.contains('squat') || lowerName.contains('lunge') || lowerName.contains('calf')) {
      return Icons.directions_run_rounded;
    } else if (lowerName.contains('curl') || lowerName.contains('tricep') || lowerName.contains('dip') || lowerName.contains('arm')) {
      return Icons.sports_gymnastics_rounded;
    } else if (lowerName.contains('pose') || lowerName.contains('stretch') || lowerFocus.contains('yoga') || lowerFocus.contains('flexibility')) {
      return Icons.self_improvement_rounded;
    } else if (lowerFocus.contains('cardio') || lowerName.contains('run') || lowerName.contains('jump')) {
      return Icons.directions_bike_rounded;
    } else if (lowerFocus.contains('recovery') || lowerFocus.contains('rest')) {
      return Icons.spa_rounded;
    }
    return Icons.bolt_rounded;
  }

  Color _getFocusThemeColor(String focus) {
    final lower = focus.toLowerCase();
    if (lower.contains('chest') || lower.contains('arms') || lower.contains('shoulder')) {
      return const Color(0xFF7B4FA3); // Deep Purple
    } else if (lower.contains('back') || lower.contains('bicep') || lower.contains('strength')) {
      return const Color(0xFF2563EB); // Royal Blue
    } else if (lower.contains('leg') || lower.contains('glute') || lower.contains('power')) {
      return const Color(0xFFDC2626); // Crimson Red
    } else if (lower.contains('yoga') || lower.contains('flexibility') || lower.contains('stretch') || lower.contains('balance')) {
      return const Color(0xFF0D9488); // Teal
    } else if (lower.contains('recovery') || lower.contains('rest') || lower.contains('yin')) {
      return const Color(0xFFD97706); // Amber
    }
    return const Color(0xFF7B4FA3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B4FA3).withValues(alpha: 0.25),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      color: Color(0xFF7B4FA3),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Loading Your Exercise Plan...",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Building high-energy exercise routines",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          if (controller.fullPlan.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B4FA3).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fitness_center_rounded, size: 72, color: Color(0xFF7B4FA3)),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "No Workout Plan Found",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We couldn't load your plan. Tap below to refresh.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () {
                        final user = _auth.currentUser;
                        if (user != null) {
                          controller.fetchWeeklyExercisePlan(user.uid);
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 22),
                      label: const Text("Refresh Workout Plan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B4FA3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 6,
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          final currentWeek = controller.weekNumber.value;
          final workoutTypeStr = controller.workoutType.value;
          final fitnessLevelStr = controller.fitnessLevel.value;
          final selectedDayIdx = controller.selectedDayIndex.value;
          final todayIdx = controller.currentWeekdayIndex.value;

          final dayPlan = controller.getSelectedDayPlan();
          final dayFocus = dayPlan?['focus'] as String? ?? 'Workout';
          final dayName = dayPlan?['day'] as String? ?? dayNamesFull[selectedDayIdx - 1];
          final List exercises = dayPlan?['exercises'] as List? ?? [];

          final themeColor = _getFocusThemeColor(dayFocus);

          // Calculate daily completion progress
          int completedCount = 0;
          for (int i = 0; i < exercises.length; i++) {
            final key = "week_${currentWeek}_day_${selectedDayIdx}_ex_$i";
            if (_completedExercises.contains(key)) completedCount++;
          }
          final progressRatio = exercises.isNotEmpty ? completedCount / exercises.length : 0.0;

          return Column(
            children: [
              // ── Bold Hero Header Banner ──
              Stack(
                children: [
                  Container(
                    height: 195,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                      image: DecorationImage(
                        image: AssetImage("assets/bg2.jpeg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 195,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF31103F).withValues(alpha: 0.92),
                          const Color(0xFF6B21A8).withValues(alpha: 0.85),
                          const Color(0xFF1E1B4B).withValues(alpha: 0.78),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Header Content
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          "WEEK $currentWeek",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      final user = _auth.currentUser;
                                      if (user != null) {
                                        controller.fetchWeeklyExercisePlan(user.uid);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                                      ),
                                      child: const Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            "${workoutTypeStr[0].toUpperCase()}${workoutTypeStr.substring(1)} Routine",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  fitnessLevelStr.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "7 Days • Personalized Schedule",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Animated Horizontal Day Ribbon Bar (Mon - Sun) ──
              Transform.translate(
                offset: const Offset(0, -22),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.09),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: List.generate(7, (index) {
                        final dayIndex = index + 1; // 1 to 7
                        final isSelected = dayIndex == selectedDayIdx;
                        final isToday = dayIndex == todayIdx;

                        return GestureDetector(
                          onTap: () => controller.selectedDayIndex.value = dayIndex,
                          child: AnimatedScale(
                            scale: isSelected ? 1.06 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF7B4FA3), Color(0xFF9D6BD8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : (isToday
                                        ? const Color(0xFF7B4FA3).withValues(alpha: 0.14)
                                        : const Color(0xFFF9FAFB)),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF7B4FA3).withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 5),
                                        ),
                                      ]
                                    : [],
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isToday ? const Color(0xFF7B4FA3) : Colors.grey.shade200),
                                  width: 1.8,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    dayNamesShort[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : (isToday ? const Color(0xFF7B4FA3) : Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (isToday)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white : const Color(0xFF7B4FA3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.local_fire_department_rounded,
                                            size: 11,
                                            color: isSelected ? const Color(0xFF7B4FA3) : Colors.white,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            "TODAY",
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: isSelected ? const Color(0xFF7B4FA3) : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Text(
                                      "Day $dayIndex",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white70 : Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // ── Bold Day Focus Header & Progress Bar Card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              _getExerciseIcon("", dayFocus),
                              color: themeColor,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dayName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: themeColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dayFocus,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: themeColor.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              "${exercises.length} Exercises",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: themeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (exercises.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Completed $completedCount of ${exercises.length} Exercises",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              "${(progressRatio * 100).toInt()}%",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressRatio,
                            minHeight: 9,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Animated Expandable Exercise Cards List ──
              Expanded(
                child: exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.spa_rounded, size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 14),
                            Text(
                              "Rest & Recovery Day",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Take rest today to boost muscle recovery and stamina.",
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final ex = exercises[index] as Map<String, dynamic>;
                          final exName = ex['name'] as String? ?? 'Exercise';
                          final sets = ex['sets'] as int? ?? 1;
                          final reps = ex['reps'] as int?;
                          final durationSec = ex['duration_seconds'] as int?;
                          final restSec = ex['rest_seconds'] as int? ?? 60;
                          final weightKg = (ex['weight_kg'] as num?)?.toDouble();
                          final equipment = ex['equipment'] as String? ?? 'Bodyweight';

                          final exKey = "week_${currentWeek}_day_${selectedDayIdx}_ex_$index";
                          final isDone = _completedExercises.contains(exKey);
                          final isExpanded = _expandedExercises.contains(exKey);
                          final iconData = _getExerciseIcon(exName, dayFocus);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDone ? const Color(0xFFF9FAFB) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDone
                                    ? const Color(0xFF10B981).withValues(alpha: 0.5)
                                    : (isExpanded ? themeColor.withValues(alpha: 0.4) : Colors.transparent),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDone
                                      ? Colors.transparent
                                      : Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Exercise Main Header Row
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                            : themeColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        isDone ? Icons.check_circle_rounded : iconData,
                                        color: isDone ? const Color(0xFF10B981) : themeColor,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exName,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: isDone ? Colors.grey.shade500 : Colors.black87,
                                              decoration: isDone ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  equipment.replaceAll('_', ' ').toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Checkbox Button
                                    GestureDetector(
                                      onTap: () => _toggleExerciseCompleted(exKey),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDone ? const Color(0xFF10B981) : Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 22,
                                          color: isDone ? Colors.white : Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // ── Bold Key Metrics Display Grid (Big Fonts) ──
                                Row(
                                  children: [
                                    _buildMetricBox(
                                      label: "SETS",
                                      value: "$sets",
                                      icon: Icons.repeat_rounded,
                                      color: const Color(0xFF2563EB),
                                    ),
                                    const SizedBox(width: 10),
                                    if (reps != null)
                                      _buildMetricBox(
                                        label: "REPS",
                                        value: "$reps",
                                        icon: Icons.tag_rounded,
                                        color: const Color(0xFF059669),
                                      ),
                                    if (durationSec != null)
                                      _buildMetricBox(
                                        label: "DURATION",
                                        value: "${durationSec}s",
                                        icon: Icons.timer_rounded,
                                        color: const Color(0xFFD97706),
                                      ),
                                    const SizedBox(width: 10),
                                    if (weightKg != null && weightKg > 0)
                                      _buildMetricBox(
                                        label: "WEIGHT",
                                        value: "$weightKg kg",
                                        icon: Icons.scale_rounded,
                                        color: const Color(0xFF7C3AED),
                                      ),
                                    const SizedBox(width: 10),
                                    _buildMetricBox(
                                      label: "REST",
                                      value: "${restSec}s",
                                      icon: Icons.alarm_rounded,
                                      color: themeColor,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // Action Row: Details & Rest Timer Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _toggleExerciseExpanded(exKey),
                                      child: Row(
                                        children: [
                                          Text(
                                            isExpanded ? "Hide Details" : "View Instructions",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: themeColor,
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up_rounded
                                                : Icons.keyboard_arrow_down_rounded,
                                            color: themeColor,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _showExerciseDetailModal(context, ex, index + 1, themeColor, dayFocus),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: themeColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 2,
                                      ),
                                      icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                                      label: const Text(
                                        "Start Exercise",
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),

                                // Expandable Details Section
                                AnimatedCrossFade(
                                  firstChild: const SizedBox.shrink(),
                                  secondChild: Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: themeColor.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: themeColor.withValues(alpha: 0.15)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.info_outline_rounded, size: 16, color: themeColor),
                                              const SizedBox(width: 6),
                                              Text(
                                                "Workout Cues & Guidance",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: themeColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Maintain proper posture during each rep. Perform $sets sets with $restSec seconds rest between sets.",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  crossFadeState: isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 250),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full Exercise Detail Modal with Large Fonts & Interactive Timer
class ExerciseDetailModal extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final int index;
  final Color themeColor;
  final String focus;

  const ExerciseDetailModal({
    super.key,
    required this.exercise,
    required this.index,
    required this.themeColor,
    required this.focus,
  });

  @override
  State<ExerciseDetailModal> createState() => _ExerciseDetailModalState();
}

class _ExerciseDetailModalState extends State<ExerciseDetailModal> {
  late int _remainingRestSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingRestSeconds = widget.exercise['rest_seconds'] as int? ?? 60;
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingRestSeconds > 0) {
        setState(() => _remainingRestSeconds--);
      } else {
        timer.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    final restSec = widget.exercise['rest_seconds'] as int? ?? 60;
    setState(() {
      _remainingRestSeconds = restSec;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exName = widget.exercise['name'] as String? ?? 'Exercise';
    final sets = widget.exercise['sets'] as int? ?? 1;
    final reps = widget.exercise['reps'] as int?;
    final durationSec = widget.exercise['duration_seconds'] as int?;
    final restSec = widget.exercise['rest_seconds'] as int? ?? 60;
    final weightKg = (widget.exercise['weight_kg'] as num?)?.toDouble();
    final equipment = widget.exercise['equipment'] as String? ?? 'Bodyweight';

    final progress = restSec > 0 ? (_remainingRestSeconds / restSec) : 0.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),

          // Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "EXERCISE #${widget.index}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: widget.themeColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 24),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Large Exercise Name (Big Typography)
          Text(
            exName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Equipment: ${equipment.replaceAll('_', ' ').toUpperCase()}",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 24),

          // Huge Metric Display Cards Grid
          Row(
            children: [
              _buildBigMetricCard(
                title: "SETS",
                value: "$sets",
                unit: "Total Sets",
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 12),
              if (reps != null)
                _buildBigMetricCard(
                  title: "REPS",
                  value: "$reps",
                  unit: "Reps / Set",
                  color: const Color(0xFF059669),
                ),
              if (durationSec != null)
                _buildBigMetricCard(
                  title: "TIME",
                  value: "$durationSec",
                  unit: "Seconds",
                  color: const Color(0xFFD97706),
                ),
              const SizedBox(width: 12),
              if (weightKg != null && weightKg > 0)
                _buildBigMetricCard(
                  title: "WEIGHT",
                  value: "$weightKg",
                  unit: "Kilograms",
                  color: const Color(0xFF7C3AED),
                ),
            ],
          ),

          const SizedBox(height: 28),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // Interactive Rest Timer Section
          Text(
            "REST TIMER",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: widget.themeColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 14,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.themeColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$_remainingRestSeconds",
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: widget.themeColor,
                    ),
                  ),
                  const Text(
                    "SECONDS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh_rounded, size: 24),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 6,
                  ),
                  icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 24),
                  label: Text(
                    _isRunning ? "PAUSE TIMER" : "START REST TIMER",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBigMetricCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
