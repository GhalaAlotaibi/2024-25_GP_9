import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'customer_signup_screen.dart';
import '/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            // Logo at the top
            Container(
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
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome Back!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                      TextSpan(
                        text:
                            '\nEnter personal details to your employee account',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Space before buttons
            Flexible(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: WelcomeButton(
                        buttonText: 'Sign in',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LogInScreen(),
                            ),
                          );
                        },
                        color: Colors.lightBlue,
                        textColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: WelcomeButton(
                        buttonText: 'Sign up',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        color: Colors.purple,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
