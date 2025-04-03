import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';

// Notifications Center
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart'; // For requesting permissions
import 'dart:io'; // For platform-specific code (request permissions for Android 13+)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Request notification permission on Android 13+ and iOS
  await requestPermission();

  runApp(MyApp());
}

// Notifications-related
Future<void> requestPermission() async {
  if (Platform.isAndroid) {
    if (await Permission.notification.isGranted) {
      print("Notification permission already granted");
    } else {
      // Request permission for Android 13+
      Permission.notification.request();
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // Request notification permissions (for iOS)
    _firebaseMessaging.requestPermission();

    // Get the FCM token and store it (or print for now)
    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
      // You can store the token in Firestore or a server for sending notifications
    });

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title}');
      // Handle the notification, show an alert, or update UI
    });

    // Handle background notifications when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'Message caused app to open from background: ${message.notification?.title}');
      // Navigate to a specific screen based on the notification
    });

    // Handle initial message when the app is opened from a terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('App opened via notification: ${message.notification?.title}');
        // Navigate to a specific screen based on the notification
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracki App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kBannerColor),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(), // Your current home screen
    );
  }
}
/* Old Code before Notifications Center import 'package:flutter/material.dart';
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
*/
