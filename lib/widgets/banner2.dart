import '../Utils/constants.dart';
import 'package:flutter/material.dart';

class Banner2 extends StatelessWidget {
  const Banner2({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 140,
        width: 388,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(color: kBannerColor, width: 1),
        ),
        child: Stack(
          children: [
            /*   Positioned(
              top: 0,
              bottom: 0,
              left: -5,
              child: Image.asset(
                'assets/images/banner2pic.png',
                fit: BoxFit.contain,
                width: 145,
              ),
            ),*/
            const Positioned(
              top: 29,
              right: 35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "! سهلناها عليك ",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: kBannerColor),
                  ),
                  Text(
                    "من هنا يمكنك إدارة كل ما يتعلق \nبعربتك",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}