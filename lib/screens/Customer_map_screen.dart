import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerMapScreen extends StatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  State<CustomerMapScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<CustomerMapScreen> {
  LatLng myCurrentLocation = const LatLng(24.7136, 46.6753);
  late GoogleMapController googleMapController;
  Set<Marker> markers = {}; // Set to hold all markers

  @override
  void initState() {
    super.initState();
    fetchFoodTruckLocations(); // Fetch food truck locations on init
  }

  Future<void> fetchFoodTruckLocations() async {
    try {
      // Fetch data from the Firestore collection
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Food_Truck').get();

      for (var doc in querySnapshot.docs) {
        // Extract location as a string
        String location = doc['location'];

        // Check if the location contains a comma
        if (location.contains(',')) {
          List<String> latLng = location.split(',');

          // Parse latitude and longitude from the string
          if (latLng.length == 2) {
            double? latitude = double.tryParse(latLng[0]);
            double? longitude = double.tryParse(latLng[1]);

            // Check if the coordinates are valid
            if (latitude != null && longitude != null) {
              LatLng position = LatLng(latitude, longitude);
              // Create a marker for the food truck
              Marker marker = Marker(
                markerId: MarkerId(doc.id), // Use document ID as marker ID
                position: position,
                infoWindow:
                    InfoWindow(title: doc['name']), // Display food truck name
              );
              setState(() {
                markers.add(marker); // Add marker to the set
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching food truck locations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            markers: markers, // Display all markers
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
              googleMapController.animateCamera(
                CameraUpdate.newLatLng(myCurrentLocation),
              );
            },
            initialCameraPosition: CameraPosition(
              target: myCurrentLocation,
              zoom: 14,
            ),
          ),
        ],
      ),
    );
  }
}
