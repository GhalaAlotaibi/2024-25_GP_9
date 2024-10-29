import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Truck_Profile.dart';  

class CreateTruck3 extends StatelessWidget {
  final String ownerId; // Owner ID
  final String truckId; // Truck ID

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
            SizedBox(
              width: 350,
              height: 350,
              child: Image.asset(
                'assets/images/logo_Tracki.png',
                fit: BoxFit.contain,
              ),
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
                        text: '!Tracki مرحبًا بك في \n',
                        style: TextStyle(
                          fontSize: 35.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF674188),
                        ),
                      ),
                      TextSpan(
                        text: //the fieled
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
            const SizedBox(height: 20),
            InkWell(
              onTap: () => _navigateToTruckProfile(context),
              child: const Text(
                "التالي",
                style: TextStyle(
                  color: Color(0xFF674188),
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
