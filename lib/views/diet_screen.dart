import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workout_planner/controllers/diet_controller.dart';
import 'home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Custom arc painter for the calorie ring
// ─────────────────────────────────────────────────────────────────────────────
class _CalorieArcPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color trackColor;
  final List<Color> arcColors;

  _CalorieArcPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    const strokeWidth = 14.0;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // Track (background arc)
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Gradient arc (progress)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        colors: arcColors,
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        transform: const GradientRotation(0),
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * progress.clamp(0.0, 1.0),
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(_CalorieArcPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Diet Screen
// ─────────────────────────────────────────────────────────────────────────────
class DietScreen extends StatelessWidget {
  final String userId;
  final String foodPreference;

  const DietScreen({
    super.key,
    required this.userId,
    required this.foodPreference,
  });

  // ── Theme tokens ─────────────────────────────────────────────────────────
  static const Color _bg = Color.fromARGB(255, 235, 227, 248);
  static const Color _purple = Color(0xFF7B4FA3);
  // ignore: unused_field — reserved for future gradient use
  static const Color _purpleDeep = Color(0xFF5C35A0);
  static const Color _white = Colors.white;

  // Macro accent colours
  static const Color _carbColor = Color(0xFF5C6BC0);   // indigo
  static const Color _proteinColor = Color(0xFF26A69A); // teal
  static const Color _fatColor = Color(0xFFF4A300);    // amber

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final controller = Get.put(DietController(userId: user.uid));

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: _purple),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Sliver App Bar ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildHeader(context),
              ),

              // ── Calorie Hero + Macros ───────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(
                  () => _buildCalorieHero(
                    calories: controller.caloriesKcal.value,
                    carbs: controller.carbsG.value,
                    protein: controller.proteinG.value,
                    fat: controller.fatsG.value,
                  ),
                ),
              ),

              // ── Macro Progress Bars ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(
                  () => _buildMacroSection(
                    carbs: controller.carbsG.value,
                    protein: controller.proteinG.value,
                    fat: controller.fatsG.value,
                    calories: controller.caloriesKcal.value,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        }),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _purple, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Diet & Nutrition",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _purple,
                ),
              ),
              Text(
                "Your daily macro targets",
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Calorie Hero (ring + numbers) ─────────────────────────────────────────
  Widget _buildCalorieHero({
    required double calories,
    required double carbs,
    required double protein,
    required double fat,
  }) {
    // Calorie progress: assume 2500 kcal daily goal as reference
    final double goal = 2500;
    final double progress = (calories / goal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B4FA3), Color(0xFF5C35A0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: 0.40),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Arc ring
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: _CalorieArcPainter(
                      progress: progress,
                      trackColor: Colors.white.withValues(alpha: 0.15),
                      arcColors: [
                        const Color(0xFFFFD700),
                        const Color(0xFFFF8C42),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: Color(0xFFFFD700), size: 22),
                      const SizedBox(height: 2),
                      Text(
                        calories.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _white,
                        ),
                      ),
                      const Text(
                        "kcal",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // Right side – quick stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's\nCalories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _heroStat("Carbs", "${carbs.toStringAsFixed(0)}g",
                      _carbColor),
                  const SizedBox(height: 8),
                  _heroStat("Protein", "${protein.toStringAsFixed(0)}g",
                      _proteinColor),
                  const SizedBox(height: 8),
                  _heroStat(
                      "Fat", "${fat.toStringAsFixed(0)}g", _fatColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String label, String value, Color dot) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
              fontSize: 13, color: Colors.white60, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
              fontSize: 13,
              color: _white,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ── Macro Progress Bars ───────────────────────────────────────────────────
  Widget _buildMacroSection({
    required double carbs,
    required double protein,
    required double fat,
    required double calories,
  }) {
    // Calculate % of total calories from each macro
    final double carbCal = carbs * 4;
    final double proteinCal = protein * 4;
    final double fatCal = fat * 9;
    final double total =
        (carbCal + proteinCal + fatCal) > 0 ? (carbCal + proteinCal + fatCal) : 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Macro Breakdown",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          _macroPill(
            label: "Carbohydrates",
            grams: carbs,
            percent: carbCal / total,
            color: _carbColor,
            icon: Icons.rice_bowl_rounded,
          ),
          const SizedBox(height: 12),
          _macroPill(
            label: "Protein",
            grams: protein,
            percent: proteinCal / total,
            color: _proteinColor,
            icon: Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 12),
          _macroPill(
            label: "Fat",
            grams: fat,
            percent: fatCal / total,
            color: _fatColor,
            icon: Icons.water_drop_rounded,
          ),
        ],
      ),
    );
  }

  Widget _macroPill({
    required String label,
    required double grams,
    required double percent,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: grams.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const TextSpan(
                      text: " g",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${(percent * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.7)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

}
