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

  // Notifications ---------------------------------------------------------------------------
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Notifications ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    page = [
      MyAppHomeScreen(customerID: widget.customerID),
      const FavoritesPage(),
      const CustomerMapScreen(),
      CustomerSettings(customerID: widget.customerID),
    ];

    // Notifications ---------------------------------------------------------------------------
    _initNotifications();
    _setupFCM();
    _startFirestoreListener();
  }

  // Notifications codes start ----------------------------------------------------------------
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

//helper method -testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
  Future<bool> _isTruckFavorited(String customerId, String truckId) async {
    try {
      final doc = await _firestore
          .collection('Favorite_Notif')
          .doc(customerId)
          .collection('favorited_trucks')
          .doc(truckId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

//testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg logic -1
  void _setupFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final truckId = message.data['truckId'];
      if (truckId == null) return;

      // Check if favorited and notification is unread
      final notificationDoc =
          await _firestore.collection('Notification').doc(truckId).get();

      if (notificationDoc.exists) {
        final isFavorited = await _firestore
            .collection('Favorite_Notif')
            .doc(widget.customerID)
            .collection('favorited_trucks')
            .doc(truckId)
            .get()
            .then((doc) => doc.exists);

        final isRead = notificationDoc.data()?['isRead'] ??
            true; // Default to true if missing

        if (isFavorited && !isRead) {
          _showNotification(
            message.notification?.title ?? 'New Message',
            message.notification?.body ?? '',
          );

          // Mark as read after showing
          await notificationDoc.reference.update({'isRead': true});
        }
      }
    });
  }

//testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg logic -2

  final Set<String> _processedNotifications = {}; // Moved outside the method
  List<String> _favoriteTruckIds = []; // Moved outside the method

  void _startFirestoreListener() {
    // 1. Listen to favorite trucks (unchanged)
    _firestore
        .collection('Favorite_Notif')
        .doc(widget.customerID)
        .collection('favorited_trucks')
        .snapshots()
        .listen((favSnapshot) {
      _favoriteTruckIds = favSnapshot.docs.map((doc) => doc.id).toList();
      print('⭐ Favorite Truck IDs: $_favoriteTruckIds');
    });

    // 2. Listen to notifications
    _firestore
        .collection('Notification')
        .orderBy('Time', descending: true)
        .snapshots()
        .listen((snapshot) async {
      // Changed to async
      if (snapshot.docs.isEmpty || _favoriteTruckIds.isEmpty) return;

      for (final doc in snapshot.docs) {
        final truckId = doc.id;
        final data = doc.data() as Map<String, dynamic>;
        final isRead = data['isRead'] ?? false; // Default to false if missing

        if (_favoriteTruckIds.contains(truckId) &&
            !_processedNotifications.contains(doc.id) &&
            !isRead) {
          // Added isRead check

          print('🚨 Showing unread notification for truck: $truckId');
          _showNotification(
            data['Title']?.toString() ?? 'إشعار جديد',
            data['Msg']?.toString() ?? 'لديك تحديث مهم',
          );

          // Mark as read
          await doc.reference.update({'isRead': true});
          _processedNotifications.add(doc.id);
        }
      }
    });
  }

//Handle notifications clicks------------------------------------------
  void _handleNotificationClick(RemoteMessage? message) {
    if (message != null) {
      print('Notification clicked: ${message.notification?.title}');

      // Redirect to MyAppHomeScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MyAppHomeScreen(customerID: widget.customerID),
        ),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    }
  }

  // Notifications codes ends ----------------------------------------------------------------

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
