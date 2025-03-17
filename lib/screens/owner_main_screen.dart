import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/screens/owner_home_screen.dart';
import 'package:tracki/screens/owner_profile.dart';
import 'package:tracki/screens/google_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracki/screens/owner_settings.dart';
import '../Utils/constants.dart';

class OwnerMainScreen extends StatefulWidget {
  final String ownerID; //
  final bool isSuspended; // New parameter for the suspension flag
  const OwnerMainScreen(
      {super.key, required this.ownerID, this.isSuspended = false});

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
    debugPrint('currentOwnerID: $currentOwnerID');
    page = [
      Center(child: CircularProgressIndicator()),
      Center(child: CircularProgressIndicator()),
      Center(child: CircularProgressIndicator()),
      Center(child: CircularProgressIndicator()),
    ];

    fetchLocation();
  }

  Future<void> fetchLocation() async {
    debugPrint('fetchLocation called');
    bool isMenuEmpty = false; // Declare isMenuEmpty here

    try {
      DocumentSnapshot truckSnapshot = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .doc(currentOwnerID)
          .get();

      if (truckSnapshot.exists) {
        Map<String, dynamic> truckData =
            truckSnapshot.data() as Map<String, dynamic>;
        debugPrint('Fetched Food Truck data: $truckData');

        isMenuEmpty = (truckData['item_images_list'] == null ||
                (truckData['item_images_list'] as List).isEmpty) &&
            (truckData['item_names_list'] == null ||
                (truckData['item_names_list'] as List).isEmpty) &&
            (truckData['item_prices_list'] == null ||
                (truckData['item_prices_list'] as List).isEmpty);

        debugPrint('item_images_list: ${truckData['item_images_list']}');
        debugPrint('item_names_list: ${truckData['item_names_list']}');
        debugPrint('item_prices_list: ${truckData['item_prices_list']}');
        debugPrint('isMenuEmpty: $isMenuEmpty');

        // Extract location if available
        if (truckData.containsKey('location')) {
          String locationString = truckData['location'];
          List<String> locationParts = locationString.split(',');
          latitude = double.tryParse(locationParts[0]);
          longitude = double.tryParse(locationParts[1]);
        } else {
          debugPrint('Location key not found in Food Truck document.');
        }
      } else {
        // Fallback to querying by ownerID
        QuerySnapshot foodTruckSnapshot = await FirebaseFirestore.instance
            .collection('Food_Truck')
            .where('ownerID', isEqualTo: currentOwnerID)
            .get();

        if (foodTruckSnapshot.docs.isNotEmpty) {
          var firstTruckDoc = foodTruckSnapshot.docs.first;
          currentOwnerID =
              firstTruckDoc.id; // Update currentOwnerID to the document ID
          Map<String, dynamic> truckData =
              firstTruckDoc.data() as Map<String, dynamic>;

          // Check if menu is empty
          isMenuEmpty = (truckData['item_images_list'] == null ||
                  (truckData['item_images_list'] as List).isEmpty) &&
              (truckData['item_names_list'] == null ||
                  (truckData['item_names_list'] as List).isEmpty) &&
              (truckData['item_prices_list'] == null ||
                  (truckData['item_prices_list'] as List).isEmpty);

          debugPrint('item_images_list: ${truckData['item_images_list']}');
          debugPrint('item_names_list: ${truckData['item_names_list']}');
          debugPrint('item_prices_list: ${truckData['item_prices_list']}');
          debugPrint('isMenuEmpty: $isMenuEmpty');

          // Extract location if available
          if (truckData.containsKey('location')) {
            String locationString = truckData['location'];
            List<String> locationParts = locationString.split(',');
            latitude = double.tryParse(locationParts[0]);
            longitude = double.tryParse(locationParts[1]);
          } else {
            debugPrint(
                'Location key not found in Food Truck document for owner.');
          }
        } else {
          debugPrint('No food truck found for ownerID: $currentOwnerID');
        }
      }

      // Update the page list after latitude and longitude are retrieved
      setState(() {
        page = [
          OwnerHomeScreen(ownerID: currentOwnerID!),
          OwnerProfile(ownerID: currentOwnerID!),
          latitude != null && longitude != null
              ? GoogleMapFlutter(
                  latitude: latitude!,
                  longitude: longitude!,
                  currentOwnerID: currentOwnerID!)
              : Center(child: Text('Failed to load map')),
          OwnerSettings(ownerID: currentOwnerID!),
        ];
      });

      // Show the dialog after setState completes
      if (isMenuEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showCongratsDialog(context);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  void showCongratsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'تهانينا! 🎉',
            textAlign: TextAlign.right, // لضبط العنوان من اليمين
          ),
          content: Text(
            'لقد تم قبول عربة الطعام الخاصة بك. يمكنك الآن إضافة محتويات قائمة الطعام.',
            textAlign: TextAlign.right, // لضبط النص من اليمين
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(); // Use rootNavigator
              },
              child: Text(
                'حسنًا',
                textAlign: TextAlign.right, // لضبط زر "حسنًا" من اليمين
              ),
            ),
          ],
        );
      },
    );
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
              label: 'الموقع الحالي'),
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
