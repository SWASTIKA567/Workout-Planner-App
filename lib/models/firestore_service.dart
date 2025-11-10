import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // fetch data saved after API 1
  Future<Map<String, dynamic>?> getWorkoutData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print("Error getting data: $e");
    }
    return null;
  }

  // store API 2 output plan
  Future<void> saveWorkoutPlan(
    String userId,
    int dayIndex,
    List<dynamic> plan,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'workout_plans': {'day_$dayIndex': plan},
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving plan: $e");
    }
  }

  //  FETCH: User Inputs
  Future<Map<String, dynamic>?> getUserInputs(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['inputs'] != null) {
          log("Found user inputs : ${data['inputs']}");
          return data['inputs'] as Map<String, dynamic>;
        } else {
          log(" 'inputs' feild missing in user doc for $userId ");
        }
      } else {
        log("No user document found for $userId");
      }
    } catch (e) {
      log(" Error getting user inputs: $e");
    }
    return null;
  }

  // SAVE: Diet Data
  Future<void> saveDietData(
    String userId,
    Map<String, dynamic> dietData,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'diet_data': dietData,
      }, SetOptions(merge: true));
      log("Diet data saved successfully for $userId");
    } catch (e) {
      log("Error saving diet data: $e");
    }
  }
}
