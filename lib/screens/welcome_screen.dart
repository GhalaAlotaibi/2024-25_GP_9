import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'login_screen.dart';
import 'user_type_selection_screen.dart';
import '/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            // Logo at the top
            SizedBox(
              width: 350, // Set desired width
              height: 350, // Set desired height
              child: Image.asset(
                'assets/images/logo_Tracki.png',
                fit: BoxFit.contain, // Maintain aspect ratio
              ),
            ),
            const SizedBox(height: 10), // Space between logo and text

            // Welcome Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center, // Center the text horizontally
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '!Tracki أهلًا بك في\n',
                        style: TextStyle(
                          fontSize: 38.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF674188),
                        ),
                      ),
                      TextSpan(
                        text:
                            '.يمكنك اكتشاف عربات الطعام في الرياض بسهولة، وتستطيع أيضًا تتبع عرباتك المفضلة، مما يجعل تجربتك مع الطعام أكثر متعة',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF674188),
                            fontWeight: FontWeight.w100),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 209), // Space before buttons

            // Align buttons at the bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: WelcomeButton(
                    buttonText: 'حساب جديد',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserTypeSelectionPage(),
                        ),
                      );
                    },
                    color: kbackgroundColor,
                    textColor: const Color(0xFF674188),
                  ),
                ),
                const SizedBox(width: 10), // Space between buttons
                Expanded(
                  child: WelcomeButton(
                    buttonText: 'تسجيل دخول',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogInScreen(),
                        ),
                      );
                    },
                    color: const Color(0xFF674188),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
