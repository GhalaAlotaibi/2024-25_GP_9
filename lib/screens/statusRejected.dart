import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this to work with Firestore

class StatusRejected extends StatelessWidget {
  final String ownerID;

  // Constructor to accept ownerID
  StatusRejected({required this.ownerID});

  // Fetch rejection message for the owner's food truck
  Future<String?> _fetchRejectMessage() async {
    try {
      // Query the Food_Truck collection for the document matching the ownerID
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .where('ownerID', isEqualTo: ownerID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there's only one document per owner
        return querySnapshot.docs.first['RejectMsg'] as String?;
      } else {
        return 'لم يتم العثور على رسالة الرفض.'; // No matching document
      }
    } catch (e) {
      return 'حدث خطأ أثناء جلب رسالة الرفض.'; // Handle errors
    }
  }

  void _goHome(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName('/')); // Pop to the root page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<String?>(
          future: _fetchRejectMessage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF674188),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ أثناء جلب البيانات.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                  ),
                ),
              );
            } else {
              final rejectMsg = snapshot.data ?? 'لم يتم العثور على رسالة الرفض.';
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    Icons.sentiment_dissatisfied,
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
                              text: 'نعتذر منك، تم رفض طلبك\n',
                              style: TextStyle(
                                fontSize: 30,
                                color: Color(0xFF674188),
                              ),
                            ),
                            TextSpan(
                              text: rejectMsg,
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () => _goHome(context),
                    child: Text(
                      'عودة إلى الصفحة الرئيسية',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF674188),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
