import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/screens/my_app_home_screen.dart';
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
  late final List<Widget> page;
 double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }
 Future<void> fetchLocation() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Food_Truck') 
          .doc(widget.ownerID) 
          .get();

      if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey('location')) {
        String locationString = data['location'];
        List<String> locationParts = locationString.split(',');
      latitude = double.parse(locationParts[0]);
          longitude = double.parse(locationParts[1]);
        }
      }
    } catch (e) {
      print('Error fetching location: $e');
    }

    setState(() {
      // Update the page  with the fetched location
      page = [
        OwnerHomeScreen(ownerID: widget.ownerID),
        OwnerProfile(ownerID: widget.ownerID),
        latitude != null && longitude != null
            ? GoogleMapFlutter(latitude: latitude!, longitude: longitude!)
            : Center(child: CircularProgressIndicator()),
        navBarPage(Iconsax.setting_21),
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
