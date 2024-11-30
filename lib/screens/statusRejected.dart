import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracki/screens/welcome_screen.dart';
import 'package:tracki/screens/Resubmit_Truck.dart';

class StatusRejected extends StatelessWidget {
  final String ownerID;

  StatusRejected({required this.ownerID});

  Future<String?> _fetchRejectMessage() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .where('ownerID', isEqualTo: ownerID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var foodTruckDoc = querySnapshot.docs.first;
        String? statusId = foodTruckDoc['statusId'] as String?;

        if (statusId != null && statusId.isNotEmpty) {
          DocumentSnapshot requestDoc = await FirebaseFirestore.instance
              .collection('Request')
              .doc(statusId)
              .get();

          if (requestDoc.exists) {
            return requestDoc['message'] as String?;
          } else {
            return 'لم يتم العثور على رسالة الرفض.';
          }
        } else {
          return 'لم يتم العثور على معرف الحالة.';
        }
      } else {
        return 'لم يتم العثور على شاحنة طعام للمالك المحدد.';
      }
    } catch (e) {
      return 'حدث خطأ أثناء جلب رسالة الرفض.';
    }
  }

  void _resubmitFoodTruck(BuildContext context) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Resubmit_Truck(ownerID: ownerID),
        ),
      );
    } catch (e) {
      print('Error resubmitting food truck: $e');
    }
  }

  void _deleteAccount(BuildContext context) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'تأكيد',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xFF674188),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text('هل أنت متأكد أنك ترغب في حذف حسابك والعربة؟'),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text('نعم'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        QuerySnapshot foodTruckQuery = await FirebaseFirestore.instance
            .collection('Food_Truck')
            .where('ownerID', isEqualTo: ownerID)
            .get();

        if (foodTruckQuery.docs.isNotEmpty) {
          var foodTruckDoc = foodTruckQuery.docs.first;
          String? statusId = foodTruckDoc['statusId'];

          if (statusId != null && statusId.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('Request')
                .doc(statusId)
                .delete();
          }

          await FirebaseFirestore.instance
              .collection('Food_Truck')
              .doc(foodTruckDoc.id)
              .delete();

          await FirebaseFirestore.instance
              .collection('Truck_Owner')
              .doc(ownerID)
              .delete();

          await FirebaseAuth.instance.currentUser?.delete();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حذف حسابك والعربة بنجاح!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              backgroundColor: Color(0xFF674188),
            ),
          );

          await Future.delayed(Duration(seconds: 2));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(),
            ),
          );
        }
      } catch (e) {
        print('Error deleting account: $e');
      }
    }
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
              final rejectMsg =
                  snapshot.data ?? 'لم يتم العثور على رسالة الرفض.';
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WelcomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    child: const Text('عودة إلى الصفحة الرئيسية'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _resubmitFoodTruck(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    child: const Text('إعادة تقديم الطلب'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _deleteAccount(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    child: const Text('حذف الحساب'),
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
