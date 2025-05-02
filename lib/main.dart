import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:google_fonts_arabic/fonts.dart';

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
// Check for internet connectivity

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracki App',
      theme: ThemeData(
        fontFamily: 'NotoSansArabic',
        colorScheme: ColorScheme.fromSeed(seedColor: kBannerColor),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(), // Your current home screen
    );
  }
}

//Local Notifications 
/* 
import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:google_fonts_arabic/fonts.dart';

// Local Notifications Center --------------------------------------------------**
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

// Local Notification Plugin Initialization ------------------------------------**
final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _initNotifications(); // Initialize local notifications -----------------**
  await requestPermission(); //Local Notifications, Permission -----------------**

  runApp(MyApp());
}

// Local notifications, Initialize ---------------------------------------------**
Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  await _notifications.initialize(
    const InitializationSettings(android: androidSettings),
  );
}

// Local notification, Show ----------------------------------------------------**
Future<void> _showNotification(String title, String message) async {
  await _notifications.show(
    0,
    title,
    message,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'tracki_channel',
        'Tracki Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

// Local Notifications-related, Permission handling ----------------------------**
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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _setupFCM();
    _startFirestoreListener();
  }

  //Local Notifications --------------------------------------------------------**
  void _setupFCM() {
    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showNotification(
        message.notification?.title ?? 'New Message',
        message.notification?.body ?? '',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
    FirebaseMessaging.instance
        .getInitialMessage()
        .then(_handleNotificationClick);
  }

// New: Firestore listener for local notifications
  void _startFirestoreListener() {
    String? _lastProcessedDocId;

    _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (final doc in snapshot.docs) {
          if (_lastProcessedDocId != doc.id) {
            final data = doc.data();
            _showNotification(
              data['title'] ?? 'إشعار جديد',
              data['message'] ?? 'لديك تحديث مهم',
            );
          }
        }

        _lastProcessedDocId = snapshot.docs.first.id;

        //printing, just for me to check
        print('تم معالجة ${snapshot.docs.length} مستند');
        print('آخر مستند معالج: $_lastProcessedDocId');
      }
    });
  }

  void _handleNotificationClick(RemoteMessage? message) {
    if (message != null) {
      print('Notification clicked: ${message.notification?.title}');
      // Add navigation logic here
    }
  }
  //Local Notifications --------------------------------------------------------**

// Check for internet connectivity

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracki App',
      theme: ThemeData(
        fontFamily: 'NotoSansArabic',
        colorScheme: ColorScheme.fromSeed(seedColor: kBannerColor),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(), // Your current home screen
    );
  }
}

*/