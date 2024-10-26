import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProfileMap extends StatefulWidget {
  final String location; // Add a parameter for location

  const ProfileMap({Key? key, required this.location}) : super(key: key);

  @override
  _ProfileMapState createState() => _ProfileMapState();
}

class _ProfileMapState extends State<ProfileMap> {
  late GoogleMapController googleMapController;
  late LatLng initialPosition;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _setInitialPosition(); // Set the initial position based on the location
  }

  void _setInitialPosition() {
    // Split the location string and parse latitude and longitude
    List<String> latLng = widget.location.split(',');
    if (latLng.length == 2) {
      double? latitude = double.tryParse(latLng[0]);
      double? longitude = double.tryParse(latLng[1]);

      if (latitude != null && longitude != null) {
        initialPosition = LatLng(latitude, longitude);
        markers.add(Marker(
          markerId: MarkerId('location'),
          position: initialPosition,
          infoWindow: InfoWindow(title: 'Food Truck Location'),
        ));
      } else {
        initialPosition = const LatLng(24.7136, 46.6753); // Default location
      }
    } else {
      initialPosition = const LatLng(24.7136, 46.6753); // Default location
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
          googleMapController.animateCamera(
            CameraUpdate.newLatLng(initialPosition),
          );
        },
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 14,
        ),
        markers: markers,
      ),
    );
  }
}
