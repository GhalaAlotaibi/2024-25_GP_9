import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/customer_reviews.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import

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

  final String apiKey = 'AIzaSyAyphWWTQc9W3Z4gWYNkP86WOeswd7mcgA';

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _launchGoogleMapsNavigation() async {
    if (_userLocation == null || _destinationLocation == null) return;

    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${_userLocation!.latitude},${_userLocation!.longitude}&destination=${_destinationLocation!.latitude},${_destinationLocation!.longitude}&travelmode=driving';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Google Maps')),
      );
    }
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
          infoWindow: const InfoWindow(title: 'موقعك'),
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: _destinationLocation!,
          infoWindow: InfoWindow(title: "موقع العربة"),
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
    // Step 1: Initial truck found confirmation
    final foundTruck = await _showSimpleDialog(
      title: 'هل عثرت على عربة الطعام؟',
      options: ['نعم', 'لا'],
    );

    if (foundTruck == 'لا') {
      // Step 2: Location complaint flow
      final fileComplaint = await _showSimpleDialog(
        title: 'هل تريد رفع شكوى عن الموقع؟',
        options: ['لا', 'نعم'],
      );

      if (fileComplaint == 'نعم') {
        await _submitComplaint('العربة غير موجودة في الموقع المحدد');
        await _showSuccessDialog('تم إرسال الشكوى بنجاح');
      }
      return;
    }

    if (foundTruck == 'نعم') {
      // Step 3: Experience feedback flow
      final actionChoice = await _showSecondialog(
        title: 'كيف كانت تجربتك؟',
        options: ['تقييم التجربة', 'لدي شكوى', 'تخطي'],
      );

      if (actionChoice == 'تقييم التجربة') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerReviews(
              truckID: widget.documentID,
              customerID: widget.customerID,
            ),
          ),
        );
      } else if (actionChoice == 'لدي شكوى') {
        await _showDetailedComplaintDialog();
      }
    }
  }

  Future<String?> _showSimpleDialog({
    required String title,
    required List<String> options,
  }) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // No button (left)
                  if (options.contains('لا'))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, 'لا'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: kBannerColor),
                            foregroundColor: kBannerColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            'لا',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),

                  // Yes button (right)
                  if (options.contains('نعم'))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, 'نعم'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBannerColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            'نعم',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDetailedComplaintDialog() async {
    final complaintController = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'تفاصيل الشكوى',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: complaintController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'صف مشكلتك بالتفصيل...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kBannerColor),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kBannerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(color: kBannerColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBannerColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('إرسال'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (submitted == true && complaintController.text.isNotEmpty) {
      await _submitComplaint(complaintController.text);
      await _showSuccessDialog('تم إرسال الشكوى بنجاح');
    }
  }

  Future<String?> _showSecondialog({
    required String title,
    required List<String> options,
  }) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Main action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // تقييم التجربة button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, 'تقييم التجربة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBannerColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'تقييم التجربة',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  // لدي شكوى button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, 'لدي شكوى'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBannerColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'لدي شكوى',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              // Skip option row
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, 'تخطي'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 91, 91, 91),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'تخطي',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBannerColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('حسناً'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const Spacer(),
          const Text(
            "موقع العربة",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 87),
          MyIconButton(
              icon: Icons.arrow_forward_ios,
              pressed: () {
                Navigator.pop(context);
              }),
          const SizedBox(width: 15),
        ],
      ),
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
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
                Positioned(
                  bottom: 12,
                  left: 10,
                  right: 150,
                  child: ElevatedButton(
                    onPressed: _launchGoogleMapsNavigation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBannerColor,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'الاتجاهات',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
