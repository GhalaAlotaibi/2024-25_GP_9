import 'package:flutter/material.dart';
import '../user_auth/firebase_auth_services.dart';
import 'package:lottie/lottie.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'package:tracki/screens/login_screen.dart';
import 'package:tracki/screens/AfterSendPasswordScreen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String? result = await _authService.sendPasswordResetEmail(
        emailController.text.trim(),
      );
      setState(() {
        isLoading = false;
      });

      if (result == "Success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال رابط استعادة كلمة المرور')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AfterSendPasswordScreen(
              email: emailController.text.trim(),
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AfterSendPasswordScreen(
              email: emailController.text.trim(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Correct the semicolon here
      child: Scaffold(
        backgroundColor: Colors.white, // Set background color to white
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
                    builder: (context) => LogInScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 333),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lottie Animation
                  Lottie.network(
                    'https://lottie.host/e003e540-46ce-4451-a9dd-d841e16e3eb0/bJveAHGJmn.json',
                    width: 400,
                    height: 350,
                    fit: BoxFit.contain,
                    // Maintain aspect ratio
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    'نسيت كلمة السر؟',
                    style: TextStyle(
                      fontSize: 24.0, // زيادة الحجم
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'لا تخاف! كل اللي عليك تدخل بريدك الإلكتروني. وراح نرسلك رابط لتغيير كلمة السر.',
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20.0),

                  // Email Input Field
                  TextFormField(
                    controller: emailController,
                    textDirection: TextDirection.rtl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.+_-]+@[a-zA-Z0-9._-]+\.[a-zA-Z]+$")
                          .hasMatch(value)) {
                        return 'يرجى إدخال بريد إلكتروني صالح';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: const Text('البريد الإلكتروني'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  ElevatedButton(
                    onPressed: isLoading ? null : sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 149, 112, 182),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // انحناء الزوايا
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 20.0),
                      elevation: 5.0,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'إرسال الرابط ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0, // حجم الخط
                            ),
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
