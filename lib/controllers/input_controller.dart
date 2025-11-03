import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_input_model.dart';
import 'api_controller.dart';

class InputController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _api = ApiController();

  Future<void> submitInputs(UserInputModel input) async {
    final userId = _auth.currentUser!.uid;

    final workoutType = await _api.fetchWorkoutType(input);

    if (workoutType != null) {
      await _firestore.collection("users").doc(userId).set({
        "inputs": input.toJson(),
        "workout_type": workoutType,
        "isSetupComplete": true,
        "timestamp": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
