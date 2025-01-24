import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapFlutter extends StatefulWidget {
  //Owner home pag (map)
  final double latitude;
  final double longitude;
  const GoogleMapFlutter({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  late LatLng myCurrentLocation;
  late GoogleMapController googleMapController;
  late Marker marker;

  @override
  void initState() {
    super.initState();
    myCurrentLocation = LatLng(widget.latitude, widget.longitude);
    marker = Marker(
      markerId: const MarkerId('static_marker'),
      position: myCurrentLocation,
      draggable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            markers: {marker}, // Display the marker
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
          //   Positioned(
          //     bottom: 30,
          //     left: MediaQuery.of(context).size.width / 2 - 75,
          //     child: Container(
          //       width: 150,
          //       height: 60,
          //       child: ElevatedButton(
          //         onPressed: () {
          //           print('Marker location: ${marker.position}');
          //         },
          //         style: ElevatedButton.styleFrom(
          //           textStyle: const TextStyle(fontSize: 15),
          //         ),
          //         child: const Text('تحديث الموقع'),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
