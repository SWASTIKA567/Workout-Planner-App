import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  String age = '';
  String gender = '';
  String height = '';
  String weight = '';
  String targetWeight = '';
  String goal = '';
  String fitnessLevel = '';
  String workoutType = '';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

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

        setState(() {
          age = inputs['age']?.toString() ?? '';
          gender = inputs['gender'] ?? '';
          height = inputs['height_cm']?.toString() ?? '';
          weight = inputs['weight_kg']?.toString() ?? '';
          targetWeight = inputs['target_weight']?.toString() ?? '';
          goal = inputs['goal'] ?? '';
          fitnessLevel = inputs['fitness_level'] ?? '';
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
        backgroundColor: const Color(0xFFB1C8FF),
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
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),

            _buildInfoTile("Age", age),
            _buildInfoTile("Gender", gender),
            _buildInfoTile("Height (cm)", height),
            _buildInfoTile("Current Weight (kg)", weight),
            _buildInfoTile("Target Weight (kg)", targetWeight),
            _buildInfoTile("Goal", goal),
            _buildInfoTile("Fitness Level", fitnessLevel),
            const SizedBox(height: 15),
            Text(
              "Workout Type: $workoutType",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 30),
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

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFB1C8FF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF004DFF),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.isNotEmpty ? value : 'Not set',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
