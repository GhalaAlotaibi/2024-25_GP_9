import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/screens/owner_home_screen.dart';
import 'package:tracki/screens/owner_profile.dart';
import 'package:tracki/screens/google_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Utils/constants.dart';

class OwnerMainScreen extends StatefulWidget {
  final String ownerID;

  const OwnerMainScreen({super.key, required this.ownerID});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int selectedIndex = 0;
  late List<Widget> page; // Declare page as late
  double? latitude;
  double? longitude;
  String? currentOwnerID; // Variable to hold the current owner/truck ID

  @override
  void initState() {
    super.initState();
    currentOwnerID = widget.ownerID;
    // Initialize the page with placeholders
    page = [
      Center(child: CircularProgressIndicator()), // Placeholder for Home
      Center(child: CircularProgressIndicator()), // Placeholder for Profile
      Center(child: CircularProgressIndicator()), // Placeholder for Map
      navBarPage(Iconsax.setting_21), // Placeholder for Settings
    ];
    fetchLocation();
  }

  Future<void> fetchLocation() async {
    try {
      // Check if the ownerID corresponds to a Food Truck
      DocumentSnapshot truckSnapshot = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .doc(currentOwnerID)
          .get();

      if (truckSnapshot.exists) {
        // It's a Food Truck ID, fetch its data
        Map<String, dynamic> truckData =
            truckSnapshot.data() as Map<String, dynamic>;
        print('Fetched Food Truck data: $truckData');

        // Extract location
        if (truckData.containsKey('location')) {
          String locationString = truckData['location'];
          List<String> locationParts = locationString.split(',');
          latitude = double.tryParse(locationParts[0]);
          longitude = double.tryParse(locationParts[1]);
        } else {
          print('Location key not found in Food Truck document.');
        }
      } else {
        // Not a Food Truck ID, check for food trucks owned by this ownerID
        QuerySnapshot foodTruckSnapshot = await FirebaseFirestore.instance
            .collection('Food_Truck')
            .where('ownerID', isEqualTo: currentOwnerID)
            .get();

        if (foodTruckSnapshot.docs.isNotEmpty) {
          // Use the first food truck found
          var firstTruckDoc = foodTruckSnapshot.docs.first;
          currentOwnerID = firstTruckDoc.id; // Update to the first truck ID
          Map<String, dynamic> truckData =
              firstTruckDoc.data() as Map<String, dynamic>;

          // Extract location
          if (truckData.containsKey('location')) {
            String locationString = truckData['location'];
            List<String> locationParts = locationString.split(',');
            latitude = double.tryParse(locationParts[0]);
            longitude = double.tryParse(locationParts[1]);
          } else {
            print('Location key not found in Food Truck document for owner.');
          }
        } else {
          print('No food trucks found for ownerID: $currentOwnerID');
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    // Update the page with the fetched location
    setState(() {
      if (currentOwnerID != null) {
        page = [
          OwnerHomeScreen(ownerID: currentOwnerID!),
          OwnerProfile(ownerID: currentOwnerID!),
          latitude != null && longitude != null
              ? GoogleMapFlutter(latitude: latitude!, longitude: longitude!)
              : Center(child: Text('Failed to load map')),
          navBarPage(Iconsax.setting_21),
        ];
      } else {
        page = [Center(child: Text('Owner ID is null. Unable to load data.'))];
      }
    });
  }

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
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 1 ? Iconsax.user4 : Iconsax.user4),
              label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 2 ? Iconsax.map5 : Iconsax.map5),
              label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(
                  selectedIndex == 3 ? Iconsax.setting_21 : Iconsax.setting_2),
              label: 'Settings'),
        ],
      ),
      body: page[selectedIndex],
    );
  }

  Widget navBarPage(iconName) {
    return Center(
      child: Icon(iconName, size: 100, color: kprimaryColor),
    );
  }
}
