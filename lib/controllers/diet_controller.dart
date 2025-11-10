import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DietController extends GetxController {
  final String userId;
  DietController({required this.userId});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var age = 0.obs;
  var gender = ''.obs;
  var heightCm = 0.0.obs;
  var weightKg = 0.0.obs;
  var targetWeight = 0.0.obs;
  var goal = ''.obs;
  var fitnessLevel = ''.obs;
  var dayIndex = 0.obs;

  var caloriesKcal = 0.0.obs;
  var carbsG = 0.0.obs;
  var fatsG = 0.0.obs;
  var proteinG = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInputsAndDayIndex();
  }

  Future<void> fetchInputsAndDayIndex() async {
    try {
      isLoading.value = true;
      log("Fetching diet data for user: $userId");

      //  Step 1: Fetch 'inputs' map from Firestore
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists || doc.data() == null) {
        log("No input data found for user: $userId");
        isLoading.value = false;
        return;
      }

      final data = doc.data()!;
      final inputs = data['inputs'] ?? {};
      final workoutPlans = data['workout_plans'] ?? {};

      log("Fetched inputs: $inputs");

      //  Step 2: Prepare body for API
      age.value = inputs['age'] ?? 0;
      gender.value = inputs['gender'] ?? '';
      heightCm.value = (inputs['height_cm'] ?? 0).toDouble();
      weightKg.value = (inputs['weight_kg'] ?? 0).toDouble();
      targetWeight.value = (inputs['target_weight'] ?? 0).toDouble();
      goal.value = inputs['goal'] ?? '';
      fitnessLevel.value = inputs['fitness_level'] ?? '';

      // Fetch day_index with detailed logging
      log("Full document data: $data");
      log("workout_plans data: $workoutPlans");
      log("workout_plans type: ${workoutPlans.runtimeType}");
      log("workout_plans keys: ${workoutPlans.keys}");

      if (workoutPlans.containsKey('day_index')) {
        log("day_index exists in workout_plans");
        final dayIndexValue = workoutPlans['day_index'];
        log("day_index raw value: $dayIndexValue");
        log("day_index type: ${dayIndexValue.runtimeType}");

        dayIndex.value = dayIndexValue is int
            ? dayIndexValue
            : int.tryParse(dayIndexValue?.toString() ?? '0') ?? 0;
      } else {
        log("day_index NOT found in workout_plans");
        dayIndex.value = 0;
      }

      log("Final day_index value: ${dayIndex.value}");

      isLoading.value = false;

      // Call API after fetching inputs
      fetchDietFromAPI();
    } catch (e) {
      log("DEBUG: Error fetching inputs -> $e");
      isLoading.value = false;
    }
  }

  //  Step 3: Call API

  Future<void> fetchDietFromAPI() async {
    try {
      final url = Uri.parse("https://macro-api-igmt.onrender.com/predict");
      log("Sending POST to $url");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "age": age.value,
          "gender": gender.value,
          "height_cm": heightCm.value,
          "weight_kg": weightKg.value,
          "target_weight": targetWeight.value,
          "goal": goal.value,
          "fitness_level": fitnessLevel.value,
          "day_index": dayIndex.value,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log("DEBUG: API Raw Response -> $responseData");

        // Check if response is a list and get the first element
        final data = responseData is List && responseData.isNotEmpty
            ? responseData[0]
            : responseData;

        // Use the helper method
        caloriesKcal.value = _parseDouble(data['calories_kcal']);
        carbsG.value = _parseDouble(data['carbs_g']);
        fatsG.value = _parseDouble(data['fats_g']);
        proteinG.value = _parseDouble(data['protein_g']);

        log(
          "DEBUG: Parsed values - Calories: ${caloriesKcal.value}, Carbs: ${carbsG.value}, Fats: ${fatsG.value}, Protein: ${proteinG.value}",
        );
      } else {
        log("DEBUG: API call failed with status ${response.statusCode}");
      }
    } catch (e) {
      log("DEBUG: Error calling Diet API -> $e");
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
