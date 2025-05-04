import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';

class StatusPending extends StatelessWidget {
  void _goHome(BuildContext context) {
    Navigator.popUntil(
        context, ModalRoute.withName('/')); // Pop to the root page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.timelapse,
              size: 80,
              color: kBannerColor,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'طلبك قيد الانتظار',
                        style: TextStyle(
                          fontSize: 30,
                          color: kBannerColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => _goHome(context),
              child: Text(
                'عودة إلى الصفحة الرئيسية',
                style: TextStyle(
                  fontSize: 18,
                  color: kBannerColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
