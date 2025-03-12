import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tracki/Utils/constants.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // To store the last known location of the food truck
  Map<String, String> _lastKnownLocations = {};

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Initialize Flutter local notifications
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Send a local notification when the location changes
  Future<void> _sendLocationChangeNotification(
      String truckName, String newLocation) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Location Update: $truckName',
      'The food truck has moved to a new location: $newLocation',
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kbackgroundColor,
        elevation: 0,
        title: const Center(
          child: Text(
            "العربات المفضلة",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Favorite')
            .doc(_auth.currentUser!.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final favoriteTruck = snapshot.data!.docs[index];
                final truckId = favoriteTruck.id;
                final truckName = favoriteTruck['truckName'];
                final currentLocation = favoriteTruck[
                    'location']; // Assuming the location is a string

                // Check if the location has changed
                if (_lastKnownLocations[truckId] != currentLocation) {
                  // Update the last known location and send a notification
                  _lastKnownLocations[truckId] = currentLocation;
                  _sendLocationChangeNotification(truckName, currentLocation);
                }

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color.fromARGB(255, 196, 73, 64)),
                          onPressed: () => _removeFavorite(favoriteTruck.id),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                truckName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                favoriteTruck['category'],
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentLocation,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(favoriteTruck['truckImage']),
                          radius: 30,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("لم يتم إضافة أي عربة طعام إلى المفضلة بعد."),
            );
          }
        },
      ),
    );
  }

  Future<void> _removeFavorite(String truckId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('Favorite')
          .doc(user.uid)
          .collection('favorites')
          .doc(truckId)
          .delete();
    }
  }
}
