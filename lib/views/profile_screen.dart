import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'choice_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _fitnessLevelController = TextEditingController();
  String workoutType = '';

  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Fetch all inputs + workout_type
  Future<void> fetchUserData() async {
    try {
      if (user == null) {
        showSnackBar("No user logged in. Please log in again.");
        setState(() => _isLoading = false);
        return;
      }

      final doc = await _firestore.collection('users').doc(user!.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final inputs = data['inputs'] ?? {};

        if (inputs.isEmpty) {
          showSnackBar("Inputs not found in user document.");
        }

        setState(() {
          _nameController.text = user!.displayName ?? '';
          _ageController.text = inputs['age']?.toString() ?? '';
          _genderController.text = inputs['gender'] ?? '';
          _heightController.text = inputs['height_cm']?.toString() ?? '';
          _weightController.text = inputs['weight_kg']?.toString() ?? '';
          _targetWeightController.text =
              inputs['target_weight']?.toString() ?? '';
          _goalController.text = inputs['goal'] ?? '';
          _fitnessLevelController.text = inputs['fitness_level'] ?? '';
          workoutType = data['workout_type'] ?? 'Not set';
          _isLoading = false;
        });

        print("Fetched data -> Workout Type: $workoutType | Inputs: $inputs");
      } else {
        setState(() => _isLoading = false);
        showSnackBar("User data not found.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackBar("Error fetching data: $e");
    }
  }

  // Save inputs
  Future<void> _saveUserData() async {
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user!.uid).set({
        'inputs': {
          'age': _ageController.text.trim(),
          'gender': _genderController.text.trim(),
          'height_cm': _heightController.text.trim(),
          'weight_kg': _weightController.text.trim(),
          'target_weight': _targetWeightController.text.trim(),
          'goal': _goalController.text.trim(),
          'fitness_level': _fitnessLevelController.text.trim(),
        },
      }, SetOptions(merge: true));

      await user!.updateDisplayName(_nameController.text.trim());
      await user!.reload();

      showSnackBar("Profile updated successfully");
      setState(() => _isEditing = false);
    } catch (e) {
      showSnackBar("Error saving profile: $e");
    }
  }

  // Logout logic
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        showSnackBar('Logged out successfully');
      }
    } catch (e) {
      showSnackBar("Error logging out: $e");
    }
  }

  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                user?.email ?? "",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField("Name", _nameController),
            _buildTextField("Age", _ageController),
            _buildTextField("Gender", _genderController),
            _buildTextField("Height (cm)", _heightController),
            _buildTextField("Current Weight (kg)", _weightController),
            _buildTextField("Target Weight (kg)", _targetWeightController),
            _buildTextField("Goal", _goalController),
            _buildTextField("Fitness Level", _fitnessLevelController),
            const SizedBox(height: 15),
            Text(
              "Workout Type: $workoutType",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 30),
            if (_isEditing)
              ElevatedButton.icon(
                onPressed: _saveUserData,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: !_isEditing,
          fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
        ),
      ),
    );
  }
}
