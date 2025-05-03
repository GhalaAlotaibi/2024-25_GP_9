import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/screens/customer_settings.dart';
import 'package:tracki/screens/favourites_page.dart';
import 'package:tracki/screens/my_app_home_screen.dart';
import 'package:tracki/screens/Customer_map_screen.dart';
import '../Utils/constants.dart';

// أضف هذه المكتبات للإشعارات و Firebase
import 'package:tracki/screens/food_truck_profile_display.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AppMainScreen extends StatefulWidget {
  final String customerID;

  const AppMainScreen({super.key, required this.customerID});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;

  // أضف هذه المتغيرات للإشعارات
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    page = [
      MyAppHomeScreen(customerID: widget.customerID),
      const FavoritesPage(),
      const CustomerMapScreen(),
      CustomerSettings(customerID: widget.customerID),
    ];

    // تهيئة الإشعارات عند بدء الصفحة
    _initNotifications();
    _setupFCM();
    _startFirestoreListener();
  }

  // ------ [أكواد الإشعارات] ------ //
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings),
    );
  }

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

  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isGranted) {
        print("Notification permission already granted");
      } else {
        await Permission.notification.request();
      }
    }
  }

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

  void _startFirestoreListener() {
    String? _lastProcessedDocId;

    _firestore
        .collection('Notification')
        .orderBy('Time', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (final doc in snapshot.docs) {
          if (_lastProcessedDocId != doc.id) {
            final data = doc.data();
            _showNotification(
              data['Title'] ?? 'إشعار جديد',
              data['Msg'] ?? 'لديك تحديث مهم',
            );
          }
        }
        _lastProcessedDocId = snapshot.docs.first.id;
      }
    });
  }

//Handle notifications clicks
  void _handleNotificationClick(RemoteMessage? message) {
    if (message != null) {
      print('Notification clicked: ${message.notification?.title}');
    }
  }

  // ------ [نهاية أكواد الإشعارات] ------ //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        iconSize: 28,
        currentIndex: selectedIndex,
        selectedItemColor: kprimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(color: kprimaryColor, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 0 ? Iconsax.home5 : Iconsax.home1),
              label: 'الرئيسية'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
              label: 'المفضلة'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 2 ? Iconsax.map5 : Iconsax.map5),
              label: 'الخريطة'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 3
                  ? Iconsax.profile_circle5
                  : Iconsax.profile_circle4),
              label: 'حسابي'),
        ],
      ),
      body: page[selectedIndex],
    );
  }
}
