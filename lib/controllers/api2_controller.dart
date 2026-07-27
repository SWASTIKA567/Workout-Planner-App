import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '/models/firestore_service.dart';

class Api2Controller extends GetxController {
  final FirestoreService _firestore = FirestoreService();

  var isLoading = false.obs;
  var fullPlan = <String, dynamic>{}.obs;
  var weekNumber = 1.obs;
  var workoutType = "".obs;
  var fitnessLevel = "".obs;
  
  // Selected day index: 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
  var selectedDayIndex = 1.obs;
  // Actual weekday from DateTime.now(): 1 = Monday ... 7 = Sunday
  var currentWeekdayIndex = DateTime.now().weekday.obs;

  @override
  void onInit() {
    super.onInit();
    // Default selected day index to actual today's weekday
    currentWeekdayIndex.value = DateTime.now().weekday;
    selectedDayIndex.value = currentWeekdayIndex.value;
  }

  /// Calculates week number starting from 1 based on user's exercise start date
  int calculateWeekNumber(DateTime? startDate) {
    if (startDate == null) return 1;
    final now = DateTime.now();
    final startAtMidnight = DateTime(startDate.year, startDate.month, startDate.day);
    final nowAtMidnight = DateTime(now.year, now.month, now.day);
    final differenceInDays = nowAtMidnight.difference(startAtMidnight).inDays;
    if (differenceInDays < 0) return 1;
    return (differenceInDays ~/ 7) + 1;
  }

  /// Fetches the weekly exercise plan from the API using user data from Firestore
  Future<void> fetchWeeklyExercisePlan(String userId) async {
    try {
      isLoading.value = true;
      log("Fetching weekly workout plan for user: $userId");

      final userData = await _firestore.getWorkoutData(userId);
      if (userData == null) {
        Get.snackbar('Error', 'User data not found');
        return;
      }

      final inputs = userData['inputs'] as Map<String, dynamic>? ?? {};
      final fetchedWorkoutType = (userData['workout_type'] ?? 'strength').toString().toLowerCase();
      final fetchedFitnessLevel = (inputs['fitness_level'] ?? 'intermediate').toString().toLowerCase();
      final gender = (inputs['gender'] ?? 'female').toString().toLowerCase();
      final equipmentAccess = (inputs['equipment_access'] ?? 'full_gym').toString().toLowerCase();

      // Calculate start_date & week_number
      DateTime? startDate;
      if (userData['start_date'] != null) {
        if (userData['start_date'] is Timestamp) {
          startDate = (userData['start_date'] as Timestamp).toDate();
        } else if (userData['start_date'] is String) {
          startDate = DateTime.tryParse(userData['start_date']);
        }
      } else if (userData['timestamp'] != null) {
        if (userData['timestamp'] is Timestamp) {
          startDate = (userData['timestamp'] as Timestamp).toDate();
        }
      }

      // If start_date was not present, set it to now in Firestore so future calculations stay consistent
      if (startDate == null) {
        startDate = DateTime.now();
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'start_date': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final calculatedWeek = calculateWeekNumber(startDate);
      weekNumber.value = calculatedWeek;
      workoutType.value = fetchedWorkoutType;
      fitnessLevel.value = fetchedFitnessLevel;

      // Update current weekday from actual time
      currentWeekdayIndex.value = DateTime.now().weekday;

      final body = {
        "workout_type": fetchedWorkoutType,
        "fitness_level": fetchedFitnessLevel,
        "gender": gender,
        "equipment_access": equipmentAccess,
        "week_number": calculatedWeek,
      };

      final url = Uri.parse("https://exercise-api-modified.onrender.com/api/exercise-plan");
      log("Sending POST to $url");
      log("Body: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      log("Status Code: ${response.statusCode}");
      log("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        
        final planData = jsonData["plan"] as Map<String, dynamic>? ?? {};
        fullPlan.value = planData;
        if (jsonData.containsKey("week_number") && jsonData["week_number"] is int) {
          weekNumber.value = jsonData["week_number"];
        }

        // Save plan in Firestore
        await _firestore.saveWeeklyWorkoutPlan(userId, weekNumber.value, planData);
        log("Successfully loaded weekly exercise plan for Week ${weekNumber.value}");
      } else {
        Get.snackbar("Error", "Failed to fetch plan: ${response.statusCode}");
      }
    } catch (e) {
      log("Error fetching plan: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper to get exercise list for currently selected day (1 to 7)
  Map<String, dynamic>? getSelectedDayPlan() {
    final dayKey = "day_${selectedDayIndex.value}";
    if (fullPlan.containsKey(dayKey)) {
      return fullPlan[dayKey] as Map<String, dynamic>;
    }
    return null;
  }
}
