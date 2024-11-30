import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tracki/screens/login_screen.dart';
import 'package:tracki/screens/forget_password_screen.dart';

class AfterSendPasswordScreen extends StatelessWidget {
  final String email; // You can pass the email here

  const AfterSendPasswordScreen({Key? key, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable back button
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.network(
              'https://lottie.host/ed3e5b4c-6271-4fed-bbea-1ab5fe98c64c/cbjmYHW7Tz.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'تم إرسال رابط تغيير كلمة المرور',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'لقد تم إرسال الرابط إلى بريدك الإلكتروني $email\nقم بالتحقق من بريدك لتغيير كلمة السر',
              style: const TextStyle(fontSize: 16.0, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LogInScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 149, 112, 182), // Set background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0), // Set padding
                elevation: 0, // Add elevation for a shadow effect
              ),
              child: const Text(
                'إنهاء',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0, // Increased font size for better visibility
                  fontWeight:
                      FontWeight.bold, // Made text bold for better visibility
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate back to the ForgetPasswordScreen when 'إعادة إرسال الرابط' is pressed
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgetPasswordScreen()),
                );
              },
              child: const Text(
                'إعادة إرسال الرابط',
                style: TextStyle(color: Color(0xFF674188)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
