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
      log("Error getting data: $e");
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
      log("Error saving plan: $e");
    }
  }
}
