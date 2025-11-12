import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '/models/firestore_service.dart';

class Api2Controller extends GetxController {
  final FirestoreService _firestore = FirestoreService();

  var isLoading = false.obs;
  var plan = <dynamic>[].obs;

  Future<void> fetchDayPlan(
    String userId,
    String fitnessLevel,
    String workoutType,
    int dayIndex,
  ) async {
    try {
      // isLoading.value = true;
      // log("Fetching workout data for user : $userId");

      // // Step 1️: Fetch workout_type & fitness_level from Firestore
      // final userData = await _firestore.getWorkoutData(userId);
      // if (userData == null) {
      //   Get.snackbar('Error', 'User data not found in Firestore');
      //   return;
      // }
      // log(userData['input']);
      // final workoutType = userData['workout_type'];
      // final fitnessLevel = userData['fitness_level'];
      // log("WorkoutType : $workoutType , Level : $fitnessLevel");

      // if (workoutType == null || fitnessLevel == null) {
      //   Get.snackbar('Error', 'Missing workout_type or fitness_level');
      //   return;
      // }

      final body = {
        "workout_type": workoutType,
        "fitness_level": fitnessLevel,
        "day_index": dayIndex,
      };

      final url = Uri.parse(
        "https://exercise-api-cvza.onrender.com/get_day_exercises",
      );
      log(" Sending POST to $url");
      log("Body : $body");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      log("Status Code : ${response.statusCode}");
      log("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        plan.value = jsonData["plan"] ?? [];

        await _firestore.saveWorkoutPlan(userId, dayIndex, plan.toList());
        Get.snackbar("Success", "Day $dayIndex plan saved!");
      } else {
        Get.snackbar("Error", "Failed: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
