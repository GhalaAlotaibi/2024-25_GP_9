import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

import 'package:tracki/Utils/constants.dart';

class RequestPage1 extends StatelessWidget {
  const RequestPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Lottie Animation
            Lottie.asset(
              // Success animation URL
              'lib/assets/pending.json',
              width: 150,
              height: 150,
              repeat: false,
            ),
            const SizedBox(height: 20),
            const Text(
              'شكرا لك',
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'تم قبول عربتك',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 50,
              width: 80,
              child: ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white)),
                onPressed: () {},
                child: const Text(
                  'ابدا',
                  style: TextStyle(fontSize: 20, color: kBannerColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
