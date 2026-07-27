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

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
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

  void _showRestTimerModal(BuildContext context, String exerciseName, int restSeconds) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RestTimerWidget(
          exerciseName: exerciseName,
          restSeconds: restSeconds,
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
      backgroundColor: const Color(0xFFF4F5F9),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B4FA3).withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      color: Color(0xFF7B4FA3),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Generating your custom weekly plan...",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Optimizing sets, reps, and recovery time",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B4FA3).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fitness_center_rounded, size: 64, color: Color(0xFF7B4FA3)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "No Exercise Plan Loaded",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We couldn't fetch your plan right now. Tap retry to reload.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        final user = _auth.currentUser;
                        if (user != null) {
                          controller.fetchWeeklyExercisePlan(user.uid);
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Retry Loading"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B4FA3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 4,
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
              // ── Eye-Catching Header Card with Background Image ──
              Stack(
                children: [
                  Container(
                    height: 190,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      image: DecorationImage(
                        image: AssetImage("assets/bg2.jpeg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 190,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4A154B).withValues(alpha: 0.88),
                          const Color(0xFF7B4FA3).withValues(alpha: 0.82),
                          const Color(0xFF111827).withValues(alpha: 0.70),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Header Top Bar Content
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
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "WEEK $currentWeek",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                            letterSpacing: 0.8,
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
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                      ),
                                      child: const Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            "${workoutTypeStr[0].toUpperCase()}${workoutTypeStr.substring(1)} Training",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  fitnessLevelStr.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "7-Day Personalized Cycle",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Dynamic Horizontal Day Ribbon (Mon - Sun) ──
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: List.generate(7, (index) {
                        final dayIndex = index + 1; // 1 to 7
                        final isSelected = dayIndex == selectedDayIdx;
                        final isToday = dayIndex == todayIdx;

                        return GestureDetector(
                          onTap: () => controller.selectedDayIndex.value = dayIndex,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                      ? const Color(0xFF7B4FA3).withValues(alpha: 0.12)
                                      : const Color(0xFFF9FAFB)),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF7B4FA3).withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isToday ? const Color(0xFF7B4FA3) : Colors.grey.shade200),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dayNamesShort[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : (isToday ? const Color(0xFF7B4FA3) : Colors.black87),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (isToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : const Color(0xFF7B4FA3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_fire_department_rounded,
                                          size: 10,
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
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white70 : Colors.grey.shade500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // ── Day Focus & Progress Card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getExerciseIcon("", dayFocus),
                              color: themeColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dayName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dayFocus,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              "${exercises.length} Exercises",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (exercises.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Completed $completedCount of ${exercises.length}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "${(progressRatio * 100).toInt()}%",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressRatio,
                            minHeight: 7,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Exercises Scrollable List ──
              Expanded(
                child: exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.spa_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              "Rest & Recovery Day",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Allow your muscles to recover and rebuild today.",
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                          final iconData = _getExerciseIcon(exName, dayFocus);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDone ? const Color(0xFFF9FAFB) : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isDone
                                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDone
                                      ? Colors.transparent
                                      : Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                            : themeColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        isDone ? Icons.check_circle_rounded : iconData,
                                        color: isDone ? const Color(0xFF10B981) : themeColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isDone ? Colors.grey.shade500 : Colors.black87,
                                              decoration: isDone ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            equipment.replaceAll('_', ' ').toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Complete Checkbox Button
                                    GestureDetector(
                                      onTap: () => _toggleExerciseCompleted(exKey),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isDone ? const Color(0xFF10B981) : Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 18,
                                          color: isDone ? Colors.white : Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Divider(height: 1, color: Colors.grey.shade200),
                                const SizedBox(height: 12),

                                // Visual Badges Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          _buildBadge(
                                            icon: Icons.repeat_rounded,
                                            text: "$sets ${sets == 1 ? 'Set' : 'Sets'}",
                                            bgColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                            textColor: const Color(0xFF2563EB),
                                          ),
                                          if (reps != null)
                                            _buildBadge(
                                              icon: Icons.tag_rounded,
                                              text: "$reps Reps",
                                              bgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                                              textColor: const Color(0xFF059669),
                                            ),
                                          if (durationSec != null)
                                            _buildBadge(
                                              icon: Icons.timer_rounded,
                                              text: "$durationSec s",
                                              bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                                              textColor: const Color(0xFFD97706),
                                            ),
                                          if (weightKg != null && weightKg > 0)
                                            _buildBadge(
                                              icon: Icons.scale_rounded,
                                              text: "$weightKg kg",
                                              bgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                              textColor: const Color(0xFF7C3AED),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Interactive Rest Timer Pill
                                    GestureDetector(
                                      onTap: () => _showRestTimerModal(context, exName, restSec),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              themeColor.withValues(alpha: 0.15),
                                              themeColor.withValues(alpha: 0.08),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: themeColor.withValues(alpha: 0.25)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.play_circle_fill_rounded,
                                              size: 16,
                                              color: themeColor,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "$restSec s Rest",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: themeColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive Rest Timer Modal Widget
class RestTimerWidget extends StatefulWidget {
  final String exerciseName;
  final int restSeconds;

  const RestTimerWidget({
    super.key,
    required this.exerciseName,
    required this.restSeconds,
  });

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.restSeconds;
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
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
    setState(() {
      _remainingSeconds = widget.restSeconds;
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
    final progress = widget.restSeconds > 0
        ? (_remainingSeconds / widget.restSeconds)
        : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF7B4FA3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_rounded, color: Color(0xFF7B4FA3), size: 16),
                SizedBox(width: 6),
                Text(
                  "REST TIMER",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7B4FA3),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.exerciseName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 28),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7B4FA3)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$_remainingSeconds",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7B4FA3),
                    ),
                  ),
                  const Text(
                    "SECONDS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh_rounded),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B4FA3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                ),
                icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 22),
                label: Text(
                  _isRunning ? "PAUSE" : "START REST",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
