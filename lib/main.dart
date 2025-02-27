import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
//24.7976, 46.5218
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracki App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kBannerColor),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
