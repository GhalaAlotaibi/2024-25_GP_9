import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/app_main_screen.dart';
import 'package:tracki/screens/owner_main_screen.dart';
import 'customer_signup_screen.dart'; // Import your signup screen
import 'user_type_selection_screen.dart'; // Import your user type selection screen

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formLogInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TextDirection.rtl, // Set text direction to RTL for the entire screen
      child: Scaffold(
        backgroundColor: kBannerColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFF674188), // Use the same color
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
                          'مرحبًا بعودتك', // Changed to Arabic
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF674188), // Match the signup color
                          ),
                          textAlign: TextAlign.right, // Align text to the right
                        ),
                        const SizedBox(height: 40.0),
                        // Email
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني'; // Arabic validation message
                            }
                            return null;
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            label: const Text('البريد الإلكتروني',
                                textAlign:
                                    TextAlign.right), // Right-aligned label
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
                        // Password
                        TextFormField(
                          obscureText: true,
                          obscuringCharacter: '*',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال الرمز السري'; // Arabic validation message
                            }
                            return null;
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            label: const Text('الرمز السري',
                                textAlign:
                                    TextAlign.right), // Right-aligned label
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
                        // Remember me and forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'تذكرني', // Changed to Arabic
                                  style: TextStyle(color: Colors.black45),
                                ),
                                Checkbox(
                                  value: rememberPassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberPassword = value!;
                                    });
                                  },
                                  activeColor: kBannerColor,
                                ),
                              ],
                            ),
                            GestureDetector(
                              child: const Text(
                                'هل نسيت كلمة المرور؟', // Changed to Arabic
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kBannerColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25.0),
                        // Log In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formLogInKey.currentState!.validate()) {
                                // If the form is valid, navigate to the home page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AppMainScreen(),
                                    //const OwnerMainScreen(),  لازم تعديل
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kBannerColor),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        // Don't have an account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'لا تملك حساب؟',
                              style: TextStyle(color: Colors.black45),
                            ),
                            const SizedBox(
                                width: 5), // Add some space between the texts
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
}
