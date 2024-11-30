import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:tracki/screens/Truck_Profile.dart';
import 'package:tracki/screens/StatusRejected.dart';
import 'login_screen.dart';

class CreateTruck3 extends StatefulWidget {
  final String ownerId;
  final String truckId;

  CreateTruck3({Key? key, required this.ownerId, required this.truckId})
      : super(key: key);

  @override
  _CreateTruck3State createState() => _CreateTruck3State();
}

class _CreateTruck3State extends State<CreateTruck3> {
  late StreamSubscription<QuerySnapshot> _statusSubscription;

  @override
  void initState() {
    super.initState();
    _checkRequestStatus();
  }

  void _checkRequestStatus() {
    _statusSubscription = FirebaseFirestore.instance
        .collection('Request')
        .where('foodTruckId', isEqualTo: widget.truckId)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final requestDoc = snapshot.docs.first;
        final data = requestDoc.data() as Map<String, dynamic>;
        final status = data['status'];

        // Check the request status
        if (status == 'accepted') {
          _navigateToOwnerMainScreen();
        } else if (status == 'rejected') {
          _navigateToStatusRejected();
        }
      }
    });
  }

  void _navigateToOwnerMainScreen() {
    _statusSubscription.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TruckProfile(truckId: widget.truckId), //
      ),
    );
  }

  void _navigateToStatusRejected() {
    _statusSubscription.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StatusRejected(ownerID: widget.ownerId),
      ),
    );
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    super.dispose();
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
            Lottie.network(
              'https://lottie.host/ed3e5b4c-6271-4fed-bbea-1ab5fe98c64c/cbjmYHW7Tz.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
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
                    builder: (context) => LogInScreen(),
                  ),
                );
              },
              child: Text(
                'لاتريد الانتظار؟ عودة إلى  صفحه تسجيل الدخول',
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
