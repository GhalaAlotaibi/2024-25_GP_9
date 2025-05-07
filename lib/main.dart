import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
 
        fontFamily:
            GoogleFonts.tajawal().fontFamily,  
        textTheme: GoogleFonts.tajawalTextTheme(
          Theme.of(context).textTheme,
        ),
     
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBannerColor,  
          
          primary: kBannerColor,
          secondary: Colors.white,
        ),
        // Apply the font to various text styles
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: GoogleFonts.tajawal(),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.tajawal(),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
