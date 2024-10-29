import '../Utils/constants.dart';
import 'package:flutter/material.dart';

class BannerToExplore extends StatelessWidget {
  const BannerToExplore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: kBannerColor,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 32,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "تعرف على أفضل عربات \n الطعام في الرياض",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      height: 1.1,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                ],
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: -20,
            child: Image.asset(
              'assets/images/Animation-1729203766245.gif',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
