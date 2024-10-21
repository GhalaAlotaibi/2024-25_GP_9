import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerMapScreen extends StatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  State<CustomerMapScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<CustomerMapScreen> {
  LatLng myCurrentLocation = const LatLng(24.7136, 46.6753);
  late GoogleMapController googleMapController;
  late Marker draggableMarker;

  @override
  void initState() {
    super.initState();
    draggableMarker = Marker(
      markerId: const MarkerId('draggable_marker'),
      position: myCurrentLocation,
      draggable: false,
    );
  }

  void updateMarkerPosition(LatLng newPosition) {
    setState(() {
      draggableMarker = draggableMarker.copyWith(positionParam: newPosition);
    });
  }

  void saveLocation() {
    print('Saved location: ${draggableMarker.position}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            markers: {draggableMarker}, // Display the marker
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
            onTap: (LatLng tappedPosition) {
              updateMarkerPosition(
                  tappedPosition); // Update marker position on tap
            },
          ),
        ],
      ),
    );
  }
}
