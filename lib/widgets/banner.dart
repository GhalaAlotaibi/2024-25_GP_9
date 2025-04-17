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
        // Using gradient for the diagonal split effect
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.centerLeft,
          colors: [
            const Color.fromARGB(209, 111, 83, 128),
            const Color.fromARGB(209, 111, 83, 128),
            kBannerColor, // Replace with your secondary color
            kBannerColor, // Replace with your secondary color
          ],
          stops: const [0.0, 0.5, 0.5, 1.0], // Creates a hard line at 50%
          transform: const GradientRotation(0.78), // 45 degrees in radians
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 32,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 255, 255, 255),
                        const Color.fromARGB(255, 222, 222, 222),
                      ],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    "تعرف على أفضل عربات \n الطعام في الرياض",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      height: 1.7,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(
            top: 23,
            right: 230,
            bottom: -21,
            left: 2,
            child: Image.asset(
              'assets/images/Animation-1729203766245.gif',

              height: 1000, // Fixed height
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}
