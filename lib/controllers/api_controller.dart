import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '/models/user_input_model.dart';

class ApiController {
  final String baseUrl = "https://workout-type-recommendation-api.onrender.com";

  Future<Map<String, dynamic>?> fetchWorkoutType(UserInputModel input) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(input.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"workout_type": data["workout_type"], "bmi": data["bmi"]};
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
