import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/welcome_screen.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'customer_signup_screen.dart';
import 'owner_signup_screen.dart';

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          MyIconButton(
            icon: Icons.arrow_forward_ios,
            pressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WelcomeScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('يرجى اختيار نوع الحساب',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF674188),
                )),
            const SizedBox(height: 40.0),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBannerColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('عميل'),
              ),
            ),
            const SizedBox(height: 40.0),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OwnerSignUpScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBannerColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('صاحب عربة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
