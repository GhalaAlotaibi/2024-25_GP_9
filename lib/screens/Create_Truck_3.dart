import 'package:flutter/material.dart';

class CreateTruck3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF674188), // Same app bar color
      ),
      body: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 5), // Reduced height
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20.0), // Adjusted space
                    const Text(
                      'قائمة الطعام',
                      style: TextStyle(
                        fontSize: 27.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF674188),
                      ),
                      textAlign: TextAlign.center, // Align text to the center
                    ),

                    const SizedBox(height: 30.0), // Spacing before the button

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Action goes here
                        },
                        child: const Text('3التالي'), // Placeholder button text
                      ),
                    ),
                    //Here I wanna add another bubble + for adding items and make the 'التالي' Button 'تأكيد'
                    const SizedBox(height: 20.0), // Spacing after the button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}