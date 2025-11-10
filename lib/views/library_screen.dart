import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: LibraryScreen()));
}

class LibraryScreen extends StatelessWidget {
  final List<String> texts = [
    'Biceps Curls',
    'Push- Ups',
    'Shoulder Press',
    ' Brisk Walk',
    'Jumping Jacks',
  ];

  final List<Color> colors = [
    Color(0XFFB1C8FF),
    Color(0xFF759EFF),
    Color.fromARGB(255, 56, 110, 236),
    Color(0xFF004DFF),

    Color.fromARGB(255, 97, 133, 239),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(23),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Color(0xFFDBE4FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    ' Workout Library',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: texts.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: colors[index],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        texts[index],

                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
