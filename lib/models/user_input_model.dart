class UserInputModel {
  int heightCm;
  int targetWeight;
  String goal;
  String gender;
  int age;
  int weightKg;
  String fitnessLevel;
  String intensityPreference;
  String primaryFocus;
  String equipmentAccess;

  UserInputModel({
    required this.heightCm,
    required this.targetWeight,
    required this.goal,
    required this.gender,
    required this.age,
    required this.weightKg,
    required this.fitnessLevel,
    required this.intensityPreference,
    required this.primaryFocus,
    required this.equipmentAccess,
  });

  Map<String, dynamic> toJson() {
    return {
      "height_cm": heightCm,
      "target_weight": targetWeight,
      "goal": goal,
      "gender": gender,
      "age": age,
      "weight_kg": weightKg,
      "fitness_level": fitnessLevel,
      "intensity_preference": intensityPreference,
      "primary_focus": primaryFocus,
      "equipment_access": equipmentAccess,
    };
  }
}
