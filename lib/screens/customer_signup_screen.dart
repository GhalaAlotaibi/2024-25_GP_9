import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/login_screen.dart';
import 'package:tracki/screens/user_type_selection_screen.dart';
import 'package:tracki/screens/welcome_screen.dart';
import 'package:tracki/user_auth/firebase_auth_services.dart';
import 'package:tracki/widgets/my_icon_button.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'app_main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool agreePersonalData = true;

 String? emailErrorText;
  String? passwordErrorText;
  String? usernameErrorText;

   bool validateAllFields() {
    setState(() {
      if (usernameController.text.isEmpty) {
        usernameErrorText = 'الرجاء إدخال اسم المستخدم';
      } else {
        usernameErrorText = null;
      }

      if (emailController.text.isEmpty) {
        emailErrorText = 'الرجاء إدخال البريد الإلكتروني';
      } else if (!RegExp(r'^[\w\.-]+@(?:gmail\.com|hotmail\.com|yahoo\.com|outlook\.com)$')
    .hasMatch(emailController.text)) {
 emailErrorText = '.الرجاء إدخال بريد إلكتروني صالح';
}else {
        emailErrorText = null;
      }

      if (passwordController.text.isEmpty) {
        passwordErrorText = 'الرجاء إدخال الرمز السري';
      } else if (passwordController.text.length < 8) {
        passwordErrorText = 'يجب أن لا يقل الرمز السري عن 8 خانات';
      } else if (!RegExp(r'^(?=.*\d)(?=.*[a-zA-Z]).{8,}$').hasMatch(passwordController.text)) {
        passwordErrorText = 'يجب أن يحتوي الرمز السري على أحرف وأرقام';
      } else {
        passwordErrorText = null;
      }
    });

    return usernameErrorText == null && emailErrorText == null && passwordErrorText == null;
  }
  
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
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
                      builder: (context) => UserTypeSelectionPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 333),
            ],
          ),
          body: Column(
            textDirection: TextDirection.rtl,
            children: [
              const Expanded(
                flex: 1,
                child: SizedBox(height: 5),
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
                    child: Form(
                      key: _formSignupKey,
                      child: Column(
                        children: [
                          const Text(
                            'إنشاء حساب جديد',
                            style: TextStyle(
                              fontSize: 27.0,
                              fontWeight: FontWeight.w600,
                              color: kBannerColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 20.0),

                           TextFormField(
                          controller: usernameController,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                usernameErrorText = 'الرجاء إدخال اسم المستخدم';
                              } else {
                                usernameErrorText = null;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            label: const Text('اسم المستخدم', textAlign: TextAlign.right),
                            hintText: 'ادخل اسم المستخدم',
                            errorText: usernameErrorText,
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                          const SizedBox(height: 25.0),
// Email
                           TextFormField(
                          controller: emailController,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                emailErrorText = 'الرجاء إدخال البريد الإلكتروني';
                              } else if (!RegExp(r'^[\w\.-]+@(?:gmail\.com|hotmail\.com|yahoo\.com|outlook\.com)$')
    .hasMatch(emailController.text)) {
 emailErrorText = '.الرجاء إدخال بريد إلكتروني صالح';
} else {
                                emailErrorText = null;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            hintText: 'ادخل البريد الإلكتروني',
                            errorText: emailErrorText,
                            hintStyle: const TextStyle(color: Colors.black26),
                            labelStyle: const TextStyle(
                              color: Colors.black54,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                          ),
                        ),
                          const SizedBox(height: 25.0), // Password
                         TextFormField(
                          controller: passwordController,
                          textDirection: TextDirection.rtl,
                          obscureText: true,
                          obscuringCharacter: '*',
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                passwordErrorText = 'الرجاء إدخال الرمز السري';
                              } else if (value.length < 8) {
                                passwordErrorText = 'يجب أن لا يقل الرمز السري عن 8 خانات';
                              } else if (!RegExp(r'^(?=.*\d)(?=.*[a-zA-Z]).{8,}$').hasMatch(value)) {
                                passwordErrorText = 'يجب أن يحتوي الرمز السري على أحرف وأرقام';
                              } else {
                                passwordErrorText = null;
                              }
                            });
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'الرمز السري',
                            hintText: 'ادخل الرمز السري',
                            errorText: passwordErrorText,
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                          ),
                        ),
                          const SizedBox(height: 25.0),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Checkbox(
                                value: agreePersonalData,
                                onChanged: (bool? value) {
                                  setState(() {
                                    agreePersonalData = value!;
                                  });
                                },
                                activeColor: kBannerColor,
                              ),
                              const Text(
                                'أوافق على  السماح بمعالجة البيانات الشخصية',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25.0),
                          // Sign up button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                               if (_formSignupKey.currentState!.validate() &&
                                  agreePersonalData &&
                                  validateAllFields()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('جاري معالجة البيانات'),
                                  ),
                                );
                                  String email = emailController.text.trim();
                                  String password =
                                      passwordController.text.trim();
                                  String username =
                                      usernameController.text.trim();

                                  String? result = await _authService
                                      .signUpWithEmailAndPassword(
                                          email, password, username);

                                  if (result != null &&
                                      result.length != 0 &&
                                      !isErrorMessage(result)) {
                                    String userID = result;
                                    await _authService
                                        .saveUserData(userID, 'Customer', {
                                      'Name': username,
                                      'email': email,
                                    });

                                    // ADD TO HISTORY
                                    await _addToHistoryCollection(userID);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('تم إنشاء الحساب بنجاح!')),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AppMainScreen(
                                              customerID: userID)),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              result ?? 'فشل انشاء الحساب')),
                                    );
                                  }
                                } else if (!agreePersonalData) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'يرجى الموافقة على معالجة البيانات الشخصية')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kBannerColor,
                                 elevation: 5.0,//added shadow
                              ),
                              child: const Text(
                                'انشاء حساب جديد',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'هل لديك حساب بالفعل؟ ',
                                  style: TextStyle(color: Colors.black45),
                                ),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (e) => const LogInScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 76, 51, 92),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
        ));
  }

// ADD TO HISTORY
  Future<void> _addToHistoryCollection(String userID) async {
    try {
      // Add a document to the History collection
      await FirebaseFirestore.instance.collection('History').add({
        'timestamp': FieldValue.serverTimestamp(), // Add the current timestamp
        'docType': 'Customer Registration',
        'Details':
            'إنشاء حساب عميل ${usernameController.text} برقم المعرف $userID',
      });
    } catch (e) {
      print("Error adding entry to History collection: $e");
    }
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
      'المستخدم غير موجود'
          'كلمة المرور خاطئة',
    ];

    return errorMessages.contains(message);
  }
}
