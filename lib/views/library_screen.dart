import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    Color(0xFF004DFF),
    Color.fromARGB(255, 70, 119, 233),
    Color(0xFF759EFF),
    Color(0XFFB1C8FF),
    Color(0xFFDBE4FF),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDBE4FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
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
                padding: EdgeInsets.all(10),
                itemCount: texts.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: colors[index],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        texts[index],

                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
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
