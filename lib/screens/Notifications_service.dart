import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initializeLocalNotifications();
    _setUpForegroundMessaging();
  }

  // Initialize local notifications
  void _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Set up foreground messaging to listen for notifications when the app is in the foreground
  void _setUpForegroundMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    });
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Tracki_Notifications', // channel id
      'تحديث موقع العربة المفضلة', // channel name
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: 'item x', // optional payload
    );
  }

  // Retrieve FCM token (to send notifications)
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }
}
