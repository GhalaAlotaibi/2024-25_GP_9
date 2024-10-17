import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  LatLng myCurrentLocation = const LatLng(24.7136, 46.6753);
  late GoogleMapController googleMapController;
  late Marker draggableMarker;

  @override
  void initState() {
    super.initState();
    draggableMarker = Marker(
      markerId: const MarkerId('draggable_marker'),
      position: myCurrentLocation,
      draggable: false, // Marker is not draggable
    );
  }

  void updateMarkerPosition(LatLng newPosition) {
    setState(() {
      draggableMarker = draggableMarker.copyWith(positionParam: newPosition);
    });
  }

  void saveLocation() {
    print(
        'Saved location: ${draggableMarker.position}'); // Save and print the current position
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
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
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width / 2 -
                75, // Adjust for centering
            child: Container(
              width: 150, // Set a larger width
              height: 60, // Set a larger height
              child: ElevatedButton(
                onPressed: saveLocation,
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 15),
                ),
                child: const Text('Save Location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
