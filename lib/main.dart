import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // Import the welcome screen from the screens folder
import 'package:firebase_core/firebase_core.dart';
//import 'screens/google_map.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(), // Set WelcomeScreen as the home
    );
  }
}
