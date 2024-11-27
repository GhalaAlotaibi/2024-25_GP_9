import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/screens/owner_home_screen.dart';
import 'package:tracki/screens/owner_profile.dart';
import 'package:tracki/screens/google_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracki/screens/owner_settings.dart';
import '../Utils/constants.dart';

class OwnerMainScreen extends StatefulWidget {
  final String ownerID;

  const OwnerMainScreen({super.key, required this.ownerID});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int selectedIndex = 0;
  late List<Widget> page;
  double? latitude;
  double? longitude;
  String? currentOwnerID;

  @override
  void initState() {
    super.initState();
    currentOwnerID = widget.ownerID;

    page = [
      Center(child: CircularProgressIndicator()),
      Center(child: CircularProgressIndicator()),
      Center(child: CircularProgressIndicator()),
      Center(child: CircularProgressIndicator()),
    ];

    fetchLocation();
  }

  Future<void> fetchLocation() async {
    try {
      DocumentSnapshot truckSnapshot = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .doc(currentOwnerID)
          .get();

      if (truckSnapshot.exists) {
        Map<String, dynamic> truckData =
            truckSnapshot.data() as Map<String, dynamic>;
        print('Fetched Food Truck data: $truckData');

        // Extract location if available
        if (truckData.containsKey('location')) {
          String locationString = truckData['location'];
          List<String> locationParts = locationString.split(',');
          latitude = double.tryParse(locationParts[0]);
          longitude = double.tryParse(locationParts[1]);
        } else {
          print('Location key not found in Food Truck document.');
        }
      } else {
        QuerySnapshot foodTruckSnapshot = await FirebaseFirestore.instance
            .collection('Food_Truck')
            .where('ownerID', isEqualTo: currentOwnerID)
            .get();

        if (foodTruckSnapshot.docs.isNotEmpty) {
          var firstTruckDoc = foodTruckSnapshot.docs.first;
          currentOwnerID = firstTruckDoc.id;
          Map<String, dynamic> truckData =
              firstTruckDoc.data() as Map<String, dynamic>;

          if (truckData.containsKey('location')) {
            String locationString = truckData['location'];
            List<String> locationParts = locationString.split(',');
            latitude = double.tryParse(locationParts[0]);
            longitude = double.tryParse(locationParts[1]);
          } else {
            print('Location key not found in Food Truck document for owner.');
          }
        } else {
          print('No food truck found for ownerID: $currentOwnerID');
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    setState(() {
      page = [
        OwnerHomeScreen(ownerID: currentOwnerID!),
        OwnerProfile(ownerID: currentOwnerID!),
        latitude != null && longitude != null
            ? GoogleMapFlutter(latitude: latitude!, longitude: longitude!)
            : Center(child: Text('Failed to load map')),
        OwnerSettings(ownerID: currentOwnerID!),
      ];
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
              label: 'الرئيسية'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 1
                  ? Iconsax.profile_circle5
                  : Iconsax.profile_circle4),
              label: 'عربتي'),
          BottomNavigationBarItem(
              icon: Icon(
                  selectedIndex == 2 ? Iconsax.location5 : Iconsax.location),
              label: 'تحديث الموقع'),
          BottomNavigationBarItem(
              icon: Icon(
                  selectedIndex == 3 ? Iconsax.setting_21 : Iconsax.setting_2),
              label: 'الإعدادات'),
        ],
      ),
      body: page[selectedIndex],
    );
  }
}
