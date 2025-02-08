import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NavigationStep {
  final String instruction;
  final String distance;
  final String duration;
  final String? maneuver;

  NavigationStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    this.maneuver,
  });
}

class EmbeddedMap extends StatefulWidget {
  final String destination; // Example: "latitude,longitude"
  final String customerID; // Customer's unique ID
  final String documentID; // Food truck document ID

  const EmbeddedMap({
    Key? key,
    required this.destination,
    required this.customerID,
    required this.documentID,
  }) : super(key: key);

  @override
  State<EmbeddedMap> createState() => _EmbeddedMapState();
}

class _EmbeddedMapState extends State<EmbeddedMap> {
  late GoogleMapController _mapController;
  bool _showDirections = false;
  List<NavigationStep> _steps = [];

  final Completer<GoogleMapController> _controller = Completer();
  final List<LatLng> _routePoints = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  LatLng? _userLocation;
  LatLng? _destinationLocation;

  final String apiKey =
      'AIzaSyAyphWWTQc9W3Z4gWYNkP86WOeswd7mcgA'; // Add your Google Maps API key here

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });

    // Set the destination directly from the provided coordinates
    _setDestinationFromCoordinates(widget.destination);

    // Check proximity to the destination
    _checkProximity();
  }

  void _setDestinationFromCoordinates(String coordinates) {
    final parts = coordinates.split(',');
    if (parts.length == 2) {
      final latitude = double.tryParse(parts[0]);
      final longitude = double.tryParse(parts[1]);
      if (latitude != null && longitude != null) {
        _destinationLocation = LatLng(latitude, longitude);
        _addMarkers();
        _fetchRoute(_userLocation!, _destinationLocation!);
      }
    }
  }

  void _addMarkers() {
    if (_userLocation != null && _destinationLocation != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: _destinationLocation!,
          infoWindow: InfoWindow(title: widget.destination),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  Future<void> _checkProximity() async {
    if (_userLocation != null && _destinationLocation != null) {
      final distance = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        _destinationLocation!.latitude,
        _destinationLocation!.longitude,
      );

      if (distance <= 200) {
        _showComplaintDialog();
      }
    }
  }

  Future<void> _showComplaintDialog() async {
    final TextEditingController _otherIssueController = TextEditingController();
    bool isTruckFound = false; // Default assumption is the truck isn't found.

    // Show dialog to ask the user if the truck was found
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage dialog state
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'تقديم شكوى',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Align(
                  // Align everything to the right
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'هل عثرت على عربة الطعام؟',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      // Bullet Points for Yes/No using Radio Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'نعم',
                                style: TextStyle(fontSize: 16),
                              ),
                              Radio<bool>(
                                value: true,
                                groupValue: isTruckFound,
                                onChanged: (value) {
                                  setState(() {
                                    isTruckFound =
                                        true; // Set truck found to true
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              const Text(
                                'لا',
                                style: TextStyle(fontSize: 16),
                              ),
                              Radio<bool>(
                                value: false,
                                groupValue: isTruckFound,
                                onChanged: (value) {
                                  setState(() {
                                    isTruckFound = false; // Set truck not found
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Additional Issue Text Field
                      const Text(
                        'صف المشكلة الأخرى (مثل الجودة أو الخدمة)',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 16),
                      ),
                      TextField(
                        controller: _otherIssueController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'تفاصيل المشكلة الأخرى',
                          labelStyle: TextStyle(fontSize: 14),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String complaintMessage = '';

                    // If the truck is not found, start with the "truck not found" message
                    if (!isTruckFound) {
                      complaintMessage = 'الشاحنة ليست في الموقع المحدد.';
                    }

                    // If the user provided another issue, append it to the complaint message
                    String otherDescription = _otherIssueController.text.trim();
                    if (otherDescription.isNotEmpty) {
                      if (complaintMessage.isNotEmpty) {
                        // Combine both complaints in one message
                        complaintMessage += ' - مشكلة أخرى: $otherDescription';
                      } else {
                        // Only other issue provided
                        complaintMessage = 'مشكلة أخرى: $otherDescription';
                      }
                    }

                    // Submit the combined complaint if there's any content
                    if (complaintMessage.isNotEmpty) {
                      _submitComplaint(complaintMessage);
                    }

                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'إرسال',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Submit complaint to Firestore
  Future<void> _submitComplaint(String description) async {
    try {
      if (description.isNotEmpty) {
        // Add the complaint to Firestore
        await FirebaseFirestore.instance.collection('Complaint').add({
          'foodTruckId': widget.documentID, // Food truck document ID
          'customerId': widget.customerID, // Customer ID
          'description': description, // Complaint description
          'status': 'pending', // Complaint status (pending)
          'timestamp': FieldValue.serverTimestamp(), // Timestamp
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تقديم الشكوى بنجاح!')),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تقديم الشكوى.')),
      );
    }
  }

  Future<void> _fetchRoute(LatLng origin, LatLng destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if ((data['routes'] as List).isNotEmpty) {
        final route = data['routes'][0];
        final points = route['overview_polyline']['points'];
        final decodedPoints = _decodePolyline(points);

        // Parse navigation steps
        final legs = route['legs'] as List;
        if (legs.isNotEmpty) {
          final steps = legs[0]['steps'] as List;
          _steps = steps.map<NavigationStep>((step) {
            return NavigationStep(
              instruction: _stripHtmlTags(step['html_instructions']),
              distance: step['distance']['text'],
              duration: step['duration']['text'],
              maneuver: step['maneuver'],
            );
          }).toList();
        }

        setState(() {
          _routePoints.addAll(decodedPoints);
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blue,
              width: 5,
              points: _routePoints,
            ),
          );
        });

        _zoomToRoute();
      }
    }
  }

  void _zoomToRoute() {
    if (_userLocation != null && _destinationLocation != null) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _userLocation!.latitude < _destinationLocation!.latitude
              ? _userLocation!.latitude
              : _destinationLocation!.latitude,
          _userLocation!.longitude < _destinationLocation!.longitude
              ? _userLocation!.longitude
              : _destinationLocation!.longitude,
        ),
        northeast: LatLng(
          _userLocation!.latitude > _destinationLocation!.latitude
              ? _userLocation!.latitude
              : _destinationLocation!.latitude,
          _userLocation!.longitude > _destinationLocation!.longitude
              ? _userLocation!.longitude
              : _destinationLocation!.longitude,
        ),
      );
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  String _stripHtmlTags(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int result = 0;
      int shift = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
        index++;
      } while (byte >= 0x20);
      int dLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dLat;

      result = 0;
      shift = 0;
      do {
        byte = encoded.codeUnitAt(index) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
        index++;
      } while (byte >= 0x20);
      int dLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dLng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLocation!,
                zoom: 14.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _markers,
              polylines: _polylines,
            ),
    );
  }
}
