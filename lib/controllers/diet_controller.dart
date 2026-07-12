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
  var bmi = 0.0.obs;
  var goal = ''.obs;
  var fitnessLevel = ''.obs;
  var intensityPreference = ''.obs;
  var primaryFocus = ''.obs;
  var equipmentAccess = ''.obs;
  var workoutType = ''.obs;
  var dayIndex = 0.obs;

  var caloriesKcal = 0.0.obs;
  var carbsG = 0.0.obs;
  var fatsG = 0.0.obs;
  var proteinG = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInputsAndDayIndex();
    listenToDayIndexChanges();
  }

  void listenToDayIndexChanges() {
    _firestore.collection('users').doc(userId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final workoutPlans = snapshot.data()!['workout_plans'] ?? {};

        if (workoutPlans.containsKey('day_index')) {
          final newDayIndex = workoutPlans['day_index'] is int
              ? workoutPlans['day_index']
              : int.tryParse(workoutPlans['day_index']?.toString() ?? '0') ?? 0;

          if (newDayIndex != dayIndex.value) {
            log("Day index changed from ${dayIndex.value} to $newDayIndex");
            dayIndex.value = newDayIndex;
            fetchDietFromAPI();
          }
        }
      }
    });
  }

  Future<void> fetchInputsAndDayIndex() async {
    try {
      isLoading.value = true;
      log("Fetching diet data for user: $userId");

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

      age.value = inputs['age'] ?? 0;
      gender.value = inputs['gender'] ?? '';
      heightCm.value = (inputs['height_cm'] ?? 0).toDouble();
      weightKg.value = (inputs['weight_kg'] ?? 0).toDouble();
      targetWeight.value = (inputs['target_weight'] ?? 0).toDouble();
      bmi.value = _parseDouble(data['bmi']);
      goal.value = inputs['goal'] ?? '';
      fitnessLevel.value = inputs['fitness_level'] ?? '';
      intensityPreference.value = inputs['intensity_preference'] ?? '';
      primaryFocus.value = inputs['primary_focus'] ?? '';
      equipmentAccess.value = inputs['equipment_access'] ?? '';
      workoutType.value = data['workout_type'] ?? '';

      log("Full document data: $data");
      log("workout_plans data: $workoutPlans");

      if (workoutPlans.containsKey('day_index')) {
        final dayIndexValue = workoutPlans['day_index'];
        dayIndex.value = dayIndexValue is int
            ? dayIndexValue
            : int.tryParse(dayIndexValue?.toString() ?? '0') ?? 0;
      } else {
        dayIndex.value = 0;
      }

      log("Final day_index value: ${dayIndex.value}");

      isLoading.value = false;

      fetchDietFromAPI();
    } catch (e) {
      log("DEBUG: Error fetching inputs -> $e");
      isLoading.value = false;
    }
  }

  Future<void> fetchDietFromAPI() async {
    try {
      // Updated to new macro-nutrients API
      final url = Uri.parse("https://macro-nutrients-api.onrender.com/predict");
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
          "bmi": bmi.value,
          "goal": goal.value,
          "fitness_level": fitnessLevel.value,
          "intensity_preference": intensityPreference.value,
          "primary_focus": primaryFocus.value,
          "equipment_access": equipmentAccess.value,
          "workout_type": workoutType.value,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log("DEBUG: API Raw Response -> $responseData");

        // New response format: { "predicted_nutrition": { "carbs_g", "fats_g", "protein_g", "total_calories" } }
        final predicted = responseData['predicted_nutrition'];
        if (predicted != null) {
          caloriesKcal.value = _parseDouble(predicted['total_calories']);
          carbsG.value = _parseDouble(predicted['carbs_g']);
          fatsG.value = _parseDouble(predicted['fats_g']);
          proteinG.value = _parseDouble(predicted['protein_g']);
        } else {
          // Fallback: try old flat format
          final data = responseData is List && responseData.isNotEmpty
              ? responseData[0]
              : responseData;
          caloriesKcal.value = _parseDouble(data['calories_kcal'] ?? data['total_calories']);
          carbsG.value = _parseDouble(data['carbs_g']);
          fatsG.value = _parseDouble(data['fats_g']);
          proteinG.value = _parseDouble(data['protein_g']);
        }

        log(
          "DEBUG: Parsed values - Calories: ${caloriesKcal.value}, Carbs: ${carbsG.value}, Fats: ${fatsG.value}, Protein: ${proteinG.value}",
        );

        await _firestore.collection('users').doc(userId).update({
          'diet_plan': {
            'calories_kcal': caloriesKcal.value,
            'carbs_g': carbsG.value,
            'fats_g': fatsG.value,
            'protein_g': proteinG.value,
            'day_index': dayIndex.value,
            'last_updated': FieldValue.serverTimestamp(),
          },
        });
      } else {
        log("DEBUG: API call failed with status ${response.statusCode}");
        log("Response body: ${response.body}");
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
