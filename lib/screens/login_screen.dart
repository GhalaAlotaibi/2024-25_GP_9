import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/app_main_screen.dart';
import 'package:tracki/screens/owner_main_screen.dart';
import 'package:tracki/screens/welcome_screen.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'customer_signup_screen.dart';
import 'user_type_selection_screen.dart';
import '../user_auth/firebase_auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracki/screens/statusPending.dart';
import 'package:tracki/screens/statusRejected.dart';
import 'package:tracki/screens/forget_password_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});
  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formLogInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool isLoading = false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (_formLogInKey.currentState!.validate() && !isLoading) {
      setState(() {
        isLoading = true;
      });
      String userID = "";
      String? result = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      setState(() {
        isLoading = false;
      });
      if (result != null && result.isNotEmpty && !isErrorMessage(result)) {
        userID = result;
        print('User ID: $userID');
        DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
            .collection('Truck_Owner')
            .doc(userID)
            .get();
        if (ownerDoc.exists) {
          // Owner *****************************************
          FirebaseFirestore.instance
              .collection('Food_Truck')
              .where('ownerID', isEqualTo: userID)
              .get()
              .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              var foodTruckDoc = querySnapshot.docs.first;
              String statusId = foodTruckDoc['statusId'];
              if (statusId != null && statusId.isNotEmpty) {
                FirebaseFirestore.instance
                    .collection('Request')
                    .doc(statusId)
                    .get()
                    .then((requestDoc) {
                  if (requestDoc.exists) {
                    String status = requestDoc['status'];
                    if (status == 'accepted' || status == 'suspended') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OwnerMainScreen(
                            ownerID: userID,
                            isSuspended: status ==
                                'suspended', // Pass the suspension flag
                          ),
                        ),
                      );
                    } else if (status == 'pending') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatusPending(),
                        ),
                      );
                    } else if (status == 'rejected') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatusRejected(ownerID: userID),
                        ),
                      );
                    }
                  } else {
                    print('No Request document found for the given statusId.');
                  }
                }).catchError((error) {
                  print('Error querying Request collection: $error');
                });
              } else {
                print('statusId is null or empty in the Food_Truck document.');
              }
            } else {
              print('No Food_Truck document found for the given ownerID.');
            }
          }).catchError((error) {
            print('Error querying Food_Truck collection: $error');
          });
        } else {
          // Customer ***************************************************
          DocumentSnapshot customerDoc = await FirebaseFirestore.instance
              .collection('Customer')
              .doc(userID)
              .get();
          if (customerDoc.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AppMainScreen(customerID: userID)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result ?? 'الحساب غير موجود')));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ?? 'فشل تسجيل الدخول')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBannerColor,
        appBar: AppBar(
          backgroundColor: kBannerColor,
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: [
            MyIconButton(
              icon: Icons.arrow_back_ios_new,
              pressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomeScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 333),
          ],
        ),
        body: Column(
          children: [
            const Expanded(
              flex: 1,
              child: SizedBox(height: 10),
            ),
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formLogInKey,
                    child: Column(
                      children: [
                        const Text(
                          'مرحبًا بعودتك',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w600,
                            color: kBannerColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 40.0),
                        TextFormField(
                          controller: emailController,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('البريد الإلكتروني',
                                textAlign: TextAlign.right),
                            hintText: 'ادخل البريد الإلكتروني',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        TextFormField(
                          controller: passwordController,
                          textDirection: TextDirection.rtl,
                          obscureText: true,
                          obscuringCharacter: '*',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال الرمز السري';
                            }
                            return null;
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            label: const Text('الرمز السري',
                                textAlign: TextAlign.right),
                            hintText: 'ادخل الرمز السري',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberPassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberPassword = value!;
                                    });
                                  },
                                  activeColor: kBannerColor,
                                ),
                                const Text(
                                  'تذكرني',
                                  style: TextStyle(color: Colors.black45),
                                )
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgetPasswordScreen()),
                                );
                              },
                              child: const Text(
                                'هل نسيت كلمة المرور؟',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kBannerColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : signIn, // Disable button if loading
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kBannerColor),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'لا تملك حساب؟',
                              style: TextStyle(color: Colors.black45),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) =>
                                        const UserTypeSelectionPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'انشاء حساب',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kprimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isErrorMessage(String message) {
    const List<String> errorMessages = [
      'يرجى إدخال بريد إلكتروني صالح',
      'البريد الإلكتروني مستخدم بالفعل',
      'تسجيل الدخول غير مفعل',
      'يجب ان تحتوي كلمة المرور 8 احرف على الاقل',
      'حدث خطأ: ',
      'كلمة المرور خاطئة',
      'المستخدم غير موجود',
      'كلمة المرور يجب أن لا تقل عن 8 خانات',
      'تسجيل الدخول غير مفعل',
      'المستخدم غير موجود',
      'كلمة المرور خاطئة',
    ];
    return errorMessages.contains(message);
  }
}
