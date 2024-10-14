import 'package:flutter/material.dart';
import 'customer_signup_screen.dart'; // Import your customer signup screen
//import 'owner_signup_screen.dart'; // Import your owner signup screen

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر نوع الحساب'), // Title in Arabic
        backgroundColor: const Color(0xFF674188),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'يرجى اختيار نوع حسابك', // Prompt in Arabic
              style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SignUpScreen(), // Navigate to Customer Sign Up
                  ),
                );
              },
              child: const Text('عميل'), // Button text for Customer
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                // context,
                //MaterialPageRoute(
                //  builder: (context) => const OwnerSignUpScreen(), // Navigate to Owner Sign Up
                // ),
                //);
              },
              child: const Text('مالك'), // Button text for Owner
            ),
          ],
        ),
      ),
    );
  }
}
