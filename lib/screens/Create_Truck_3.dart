import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Truck_Profile.dart'; // Import the Truck_Profile.dart file

class CreateTruck3 extends StatelessWidget {
  final String ownerId; // Owner ID
  final String truckId; // Truck ID

  CreateTruck3({Key? key, required this.ownerId, required this.truckId})
      : super(key: key);

  void _navigateToTruckProfile(BuildContext context) {
    // Navigate to Truck_Profile screen and pass the truckId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TruckProfile(truckId: truckId), // Pass the truckId to TruckProfile
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            // Logo at the top
            SizedBox(
              width: 350, // Set desired width
              height: 350, // Set desired height
              child: Image.asset(
                'assets/images/logo_Tracki.png', // Replace with your logo path
                fit: BoxFit.contain, // Maintain aspect ratio
              ),
            ),
            const SizedBox(height: 20), // Space between logo and text
            // Welcome Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '!Tracki مرحبًا بك في \n',
                        style: TextStyle(
                          fontSize: 35.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF674188),
                        ),
                      ),
                      TextSpan(
                        text:
                            'تمت إضافة عربتك بنجاح، يمكنك الآن عرض ملفك الشخصي',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF674188),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Space 

InkWell(
  onTap: () => _navigateToTruckProfile(context), // Navigate on tap
  child: const Text(
    "عرض الملف الشخصي", // Link text
    style: TextStyle(
      color: Color(0xFF674188), // Link color
      fontSize: 20, // Font size for the link
      decoration: TextDecoration.underline, // Underline for link effect
    ),
  ),
),


          ],
        ),
      ),
    );
  }
}
