import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/user_type_selection_screen.dart';
import 'package:tracki/screens/welcome_screen.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_main_screen.dart';
import '../user_auth/firebase_auth_services.dart';

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
          backgroundColor: const Color(0xFF674188),
          appBar: AppBar(
            backgroundColor: const Color(0xFF674188),
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
                              color: Color(0xFF674188),
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 20.0),

                          TextFormField(
                            controller: usernameController,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال اسم المستخدم';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              label: const Text('اسم المستخدم',
                                  textAlign: TextAlign.right),
                              hintText: 'ادخل اسم المستخدم',
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
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 25.0),
// Email
                          TextFormField(
                            controller: emailController,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال البريد الإلكتروني';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              hintText: 'ادخل البريد الإلكتروني',
                              hintStyle: const TextStyle(color: Colors.black26),
                              labelStyle: const TextStyle(
                                color: Colors.black54,
                              ),
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
                              contentPadding:
                                  const EdgeInsets.fromLTRB(10, 15, 10, 15),
                            ),
                          ),
                          const SizedBox(height: 25.0), // Password
                          TextFormField(
                            controller: passwordController,
                            textDirection: TextDirection.rtl,
                            obscureText: true,
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال الرمز السري';
                              }
                              return null;
                            },
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              labelText: 'الرمز السري',
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
                              contentPadding:
                                  const EdgeInsets.fromLTRB(10, 15, 10, 15),
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
                                activeColor:
                                    const Color.fromARGB(255, 105, 99, 197),
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
                                    agreePersonalData) {
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
                                      color: Color.fromARGB(255, 139, 65, 174),
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
//
