import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '/models/user_input_model.dart';

class ApiController {
  final String baseUrl = "https://workout-type-api.onrender.com";

  Future<String?> fetchWorkoutType(UserInputModel input) async {
    try {
      final response = await http.post(
        Uri.parse("https://workout-type-api.onrender.com/predict_workout_type"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(input.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["workout_type"];
      } else {
        log("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("API Error: $e");
      return null;
    }
  }
}
