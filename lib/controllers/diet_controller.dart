import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '/models/firestore_service.dart';

class DietController extends GetxController {
  final FirestoreService _firestore = FirestoreService();

  var isLoading = false.obs;
  var calories = 0.0.obs;
  var carbs = 0.0.obs;
  var fat = 0.0.obs;
  var protein = 0.0.obs;

  Future<void> fetchDietData(String userId) async {
    try {
      isLoading.value = true;
      log("Fetching diet data for user: $userId");

      //  Step 1: Fetch 'inputs' map from Firestore
      final userDoc = await _firestore.getUserInputs(userId);

      if (userDoc == null || userDoc['inputs'] == null) {
        Get.snackbar('Error', 'No input data found for user');
        log("No input data found for user: $userId");
        return;
      }

      final inputs = userDoc['inputs'];
      log("Fetched inputs: $inputs");

      //  Step 2: Prepare body for API
      final body = {
        "day_index": 1, // or pass dynamically if needed
        "age": inputs["age"],
        "gender": inputs["gender"],
        "height_cm": inputs["height_cm"],
        "weight_kg": inputs["weight_kg"],
        "target_weight": inputs["target_weight"],
        "goal": inputs["goal"],
        "fitness_level": inputs["fitness_level"],
      };

      log("Sending POST to API with body: $body");

      //  Step 3: Call API
      final response = await http.post(
        Uri.parse("https://macro-api-igmt.onrender.com/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      log("API response code: ${response.statusCode}");
      log("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)[0];

        calories.value = result["calories_kcal"] ?? 0;
        carbs.value = result["carbs_g"] ?? 0;
        fat.value = result["fats_g"] ?? 0;
        protein.value = result["protein_g"] ?? 0;

        //  Step 4: Save diet data to Firestore
        await _firestore.saveDietData(userId, result);

        Get.snackbar("Success", "Diet data updated!");
      } else {
        Get.snackbar("Error", "Failed to fetch diet data");
      }
    } catch (e) {
      log("Error fetching diet data: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
