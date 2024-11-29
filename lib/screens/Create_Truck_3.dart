import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Truck_Profile.dart';
import 'package:tracki/screens/welcome_screen.dart';

class CreateTruck3 extends StatelessWidget {
  final String ownerId; 
  final String truckId;

  CreateTruck3({Key? key, required this.ownerId, required this.truckId})
      : super(key: key);

  void _navigateToTruckProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TruckProfile(truckId: truckId),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.local_shipping,
              size: 80,
              color: Color(0xFF674188),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'تم إرسال طلب إضافة عربتك بنجاح',
                        style: TextStyle(
                          fontSize: 30,
                          color: Color(0xFF674188),
                        ),
                      ),
                      TextSpan(
                        text: '\n ...يرجى الإنتظار حتى يتم قبول عربتك',
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF674188),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
TextButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomeScreen(),
      ),
    );
  },
  child: Text(
    'عودة إلى الصفحة الرئيسية',
    style: TextStyle(
      fontSize: 18,
      color: Color(0xFF674188),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
