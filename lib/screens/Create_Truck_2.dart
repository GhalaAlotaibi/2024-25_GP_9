import 'package:flutter/material.dart';
import 'Create_Truck_3.dart'; // Make sure this import matches the actual file name

class CreateTruck2 extends StatelessWidget {
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
                    const Text(
                      'تحديد الموقع',
                      style: TextStyle(
                        fontSize: 27.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF674188),
                      ),
                      textAlign: TextAlign.center, // Align text to the center
                    ),
                    const SizedBox(height: 20.0), // Adjusted space

                    // Google API Container
                    Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(
                          color: const Color.fromARGB(255, 231, 233, 235),
                          width: 2.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Here Will Be The Location API', 
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center, // Center align text
                      ),
                    ),

                    const SizedBox(height: 30.0), // Spacing before the button

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to CreateTruck3 when pressed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateTruck3(),
                            ),
                          );
                        },
                        child: const Text('التالي 2'), // Placeholder button text
                      ),
                    ),
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