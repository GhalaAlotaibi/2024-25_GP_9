import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'login_screen.dart';
import 'user_type_selection_screen.dart';
import '/widgets/welcome_button.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            // Onboarding Animations and Titles
            Expanded(
              flex: 3,
              child: PageView(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildOnboardingPage(
                    'استكشف',
                    '!تقدر تعرف وتستكشف كل العربات القريبة منك',
                    'https://lottie.host/1364e605-6493-4806-98ea-80864a88276f/FbRbB7K93q.json',
                  ),
                  _buildOnboardingPage(
                    'قيم وشارك رأيك',
                    'قيم العربات وشارك تجربتك مع باقي المستخدمين',
                    'https://lottie.host/03d13914-822d-419e-bf79-4b0babeeb42a/Id7oyVWYDU.json',
                  ),
                  _buildOnboardingPage(
                      'إشعارات أول بأول',
                      'لاتخاف! راح توصلك اشعارات اذا وحده من عرباتك المفضله غيرت الموقع',
                      "https://lottie.host/eade0a2c-d6e6-49c6-9f87-bb8482e6a4df/gyM2odgyWP.json"),
                ],
              ),
            ),

            // Page Indicators close to the animation
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3, // Number of pages
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 10,
                  width: _currentPage == index ? 20 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color.fromARGB(255, 90, 62, 115)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 140), // Space between indicators and buttons

            // Buttons at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserTypeSelectionPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            color: Color(0xFF674188),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'حساب جديد',
                        style: TextStyle(
                          color: Color(0xFF674188),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LogInScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 76, 58, 91),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'تسجيل دخول',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
      String title, String description, String lottieUrl) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation
          SizedBox(
            width: 300,
            height: 300,
            child: Lottie.network(
              lottieUrl,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          // Title Text
          Text(
            title,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          // Description Text
          Text(
            description,
            style: const TextStyle(
              fontSize: 20.0,
              color: Color.fromARGB(255, 54, 54, 54),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
