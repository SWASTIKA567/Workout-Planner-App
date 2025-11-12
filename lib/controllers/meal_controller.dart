import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MealController extends GetxController {
  final String userId;
  MealController({required this.userId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var foodPreference = ''.obs;
  var breakfast = ''.obs;
  var lunch = ''.obs;
  var dinner = ''.obs;
  var eveningSnack = ''.obs;

  var caloriesKcal = 0.0.obs;
  var carbsG = 0.0.obs;
  var fatsG = 0.0.obs;
  var proteinG = 0.0.obs;
  var dayIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    listenToDietPlanChanges();
    fetchSavedMealPlan();
  }

  void listenToDietPlanChanges() {
    log("Setting up diet plan listener for user: $userId");

    _firestore.collection('users').doc(userId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final dietPlan = data['diet_plan'];

        if (dietPlan != null) {
          final newCalories = _parseDouble(dietPlan['calories_kcal']);
          final newCarbs = _parseDouble(dietPlan['carbs_g']);
          final newFats = _parseDouble(dietPlan['fats_g']);
          final newProtein = _parseDouble(dietPlan['protein_g']);
          final newDayIndex = dietPlan['day_index'] ?? 0;

          log("📥 Diet plan update detected:");
          log(
            "   OLD - Cal: ${caloriesKcal.value}, Carbs: ${carbsG.value}, Protein: ${proteinG.value}, Fats: ${fatsG.value}, Day: ${dayIndex.value}",
          );
          log(
            "   NEW - Cal: $newCalories, Carbs: $newCarbs, Protein: $newProtein, Fats: $newFats, Day: $newDayIndex",
          );

          bool macrosChanged =
              newCalories != caloriesKcal.value ||
              newCarbs != carbsG.value ||
              newFats != fatsG.value ||
              newProtein != proteinG.value;

          bool dayChanged = newDayIndex != dayIndex.value;

          caloriesKcal.value = newCalories;
          carbsG.value = newCarbs;
          fatsG.value = newFats;
          proteinG.value = newProtein;
          dayIndex.value = newDayIndex;

          if (macrosChanged || dayChanged) {
            log(" Macros/Day changed, fetching new meal plan");

            String currentFoodPref = foodPreference.value.isEmpty
                ? 'vegetarian'
                : foodPreference.value;

            fetchMealPlanFromAPI(currentFoodPref);
          } else {
            log("No significant changes, skipping meal API call");
          }
        }
      }
    });
  }

  Future<void> changeDayAndFetchMeals(int newDayIndex) async {
    log("User manually changing day from ${dayIndex.value} to $newDayIndex");

    String currentFoodPref = foodPreference.value.isEmpty
        ? 'vegetarian'
        : foodPreference.value;

    final originalDayIndex = dayIndex.value;
    dayIndex.value = newDayIndex;

    await fetchMealPlanFromAPI(currentFoodPref);
  }

  Future<void> fetchMealPlanFromAPI(String foodPref) async {
    try {
      isLoading.value = true;
      foodPreference.value = foodPref;

      final url = Uri.parse("https://meal-plan-new-api.onrender.com/predict");
      log(" Sending POST to $url");

      final requestBody = {
        "calories_kcal": caloriesKcal.value,
        "protein_g": proteinG.value,
        "carbs_g": carbsG.value,
        "fats_g": fatsG.value,
        "day_index": dayIndex.value,
        "food_preference": foodPref,
      };

      log("Request body: $requestBody");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log(" Meal Plan API Response -> $responseData");

        final predictions = responseData['predictions'];
        if (predictions != null && predictions.isNotEmpty) {
          final mealPlan = predictions[0];

          breakfast.value = mealPlan['breakfast'] ?? '';
          lunch.value = mealPlan['lunch'] ?? '';
          dinner.value = mealPlan['dinner'] ?? '';
          eveningSnack.value = mealPlan['evening_snack'] ?? '';

          log(" Meal plan fetched successfully");
          log("   Breakfast: ${breakfast.value}");
          log("   Lunch: ${lunch.value}");
          log("   Dinner: ${dinner.value}");
          log("   Evening Snack: ${eveningSnack.value}");

          await saveMealPlanToFirestore();
        } else {
          log(" No predictions found in response");
        }
      } else {
        log(" Meal plan API failed with status ${response.statusCode}");
        log("Response body: ${response.body}");
      }

      isLoading.value = false;
    } catch (e) {
      log(" Error calling Meal Plan API: $e");
      isLoading.value = false;
    }
  }

  Future<void> saveMealPlanToFirestore() async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'meal_plan': {
          'breakfast': breakfast.value,
          'lunch': lunch.value,
          'dinner': dinner.value,
          'evening_snack': eveningSnack.value,
          'food_preference': foodPreference.value,
          'day_index': dayIndex.value,
          'last_updated': FieldValue.serverTimestamp(),
        },
      });

      log(" Meal plan saved to Firestore successfully");
    } catch (e) {
      log(" Error saving meal plan to Firestore: $e");
    }
  }

  Future<void> fetchSavedMealPlan() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        final mealPlan = doc.data()!['meal_plan'];

        if (mealPlan != null) {
          breakfast.value = mealPlan['breakfast'] ?? '';
          lunch.value = mealPlan['lunch'] ?? '';
          dinner.value = mealPlan['dinner'] ?? '';
          eveningSnack.value = mealPlan['evening_snack'] ?? '';
          foodPreference.value = mealPlan['food_preference'] ?? '';

          log(" Loaded saved meal plan from Firestore");
        }
      }
    } catch (e) {
      log(" Error fetching saved meal plan: $e");
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
