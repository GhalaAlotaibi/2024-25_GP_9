import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracki/Utils/constants.dart';
import 'Create_Truck_3.dart';

class CreateTruck2 extends StatefulWidget {
  final String ownerId; // Capture the owner ID
  final String truckName; // Truck name
  final String businessLogo; // Business logo URL
  final String truckImage; // Truck image URL
  final String selectedCategory; // Selected category
  final String description; // Description
  final String operatingHours; // Combined operating hours
  final String licenseNo; // License Number

  CreateTruck2({
    Key? key,
    required this.ownerId,
    required this.truckName,
    required this.businessLogo,
    required this.truckImage,
    required this.selectedCategory,
    required this.description,
    required this.operatingHours, // Pass combined operating hours
    required this.licenseNo, // Accept License Number
  }) : super(key: key);

  @override
  _CreateTruck2State createState() => _CreateTruck2State();
}

class _CreateTruck2State extends State<CreateTruck2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LatLng _selectedLocation = LatLng(24.7136, 46.6753); // Default location
  late GoogleMapController _mapController;

  Future<void> _saveTruckDetails(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      CollectionReference trucks =
          FirebaseFirestore.instance.collection('Food_Truck');

      // Create truck data to save
      Map<String, dynamic> truckData = {
        'name': truckName,
        'businessLogo': businessLogo,
        'truckImage': truckImage,
        'category': selectedCategory,
        'description': description,
        'operatingHours': operatingHours,
        'ownerID': ownerId,
       location':
            '${_selectedLocation.latitude},${_selectedLocation.longitude}',
        'licenseNo': licenseNo, //License Number
        'rating': '0',
        'ratingsCount': 0,
        'item_names_list': [],
        'item_prices_list': [],
        'item_images_list': [],
      };

      try {
        DocumentReference truckRef = await trucks.add(truckData);
        String truckId = truckRef.id;

        print("Truck details saved successfully with ID: $truckId");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CreateTruck3(ownerId: widget.ownerId, truckId: truckId),
          ),
        );
      } catch (e) {
        print("Error saving truck details: $e");
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBannerColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF674188),
      ),
      body: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 5)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'تحديد موقع العربة',
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF674188),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),

                      // Google Maps Container
                      Container(
                        height: 400,
                        width: double.infinity,
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation,
                            zoom: 14,
                          ),
                          onTap: (LatLng location) {
                            setState(() {
                              _selectedLocation =
                                  location; // Update selected location
                            });
                          },
                          markers: {
                            Marker(
                              markerId: MarkerId('selected_location'),
                              position: _selectedLocation,
                            ),
                          },
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _saveTruckDetails(context);
                          },
                          child: const Text('التالي'), // "Next" button text
                        ),
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
