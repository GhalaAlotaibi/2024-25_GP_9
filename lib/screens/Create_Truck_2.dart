import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'Create_Truck_3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateTruck2 extends StatefulWidget {
  final String ownerId;
  final String truckName;
  final String businessLogo;
  final String truckImage;
  final String selectedCategory;
  final String description;
  final String operatingHours;
  final String licenseNo;
  final String licensePDF;

  CreateTruck2({
    Key? key,
    required this.ownerId,
    required this.truckName,
    required this.businessLogo,
    required this.truckImage,
    required this.selectedCategory,
    required this.description,
    required this.operatingHours,
    required this.licenseNo,
    required this.licensePDF,
  }) : super(key: key);

  @override
  _CreateTruck2State createState() => _CreateTruck2State();
}

class _CreateTruck2State extends State<CreateTruck2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LatLng _selectedLocation = LatLng(24.7136, 46.6753);
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _saveTruckDetails(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      CollectionReference trucks =
          FirebaseFirestore.instance.collection('Food_Truck');
      CollectionReference requests =
          FirebaseFirestore.instance.collection('Request');
      //HISTORY
      CollectionReference history =
          FirebaseFirestore.instance.collection('History');

      try {
        DocumentReference requestRef = await requests.add({
          'foodTruckId': '',
          'message': 'طلب إضافة عربة جديد',
          'status': 'pending',
        });
        String requestId = requestRef.id;

        DocumentReference truckRef = await trucks.add({
          'name': widget.truckName,
          'businessLogo': widget.businessLogo,
          'truckImage': widget.truckImage,
          'categoryId': widget.selectedCategory,
          'description': widget.description,
          'operatingHours': widget.operatingHours,
          'ownerID': widget.ownerId,
          'location':
              '${_selectedLocation.latitude},${_selectedLocation.longitude}',
          'licenseNo': widget.licenseNo, // 🔍 This should be a number
          'licensePDF': widget.licensePDF, // 🔍 This should be a URL
          'rating': '0',
          'ratingsCount': 0,
          'item_names_list': [],
          'item_prices_list': [],
          'item_images_list': [],
          'statusId': requestId, // Link to the Request document
          'DateofReg': FieldValue.serverTimestamp(), //For Truck's Analysis
          'TruckCounter': 0, //Counter for most clicked food truck
        });

        String truckId = truckRef.id;

        //Update the Request document with the foodTruckId
        await requestRef.update({
          'foodTruckId': truckId,
        });

        print(
            "Truck and request created successfully. Truck ID: $truckId, Request ID: $requestId");

        //ADD TO HISTORY
        await history.add({
          'docType': 'Food Truck Registration Request',
          'Details': 'طلب تسجيل عربة ${widget.truckName} برقم المعرف $truckId',
          'timestamp': FieldValue.serverTimestamp(),
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CreateTruck3(ownerId: widget.ownerId, truckId: truckId),
          ),
        );
      } catch (e) {
        print("Error saving truck or request details: $e");
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<LatLng?> _searchLocation(String query) async {
    final encodedQuery = Uri.encodeQueryComponent(query);

    //THIS KEY SHOULD BE REMOVED BEFORE UPLOADING TO GITHUB
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedQuery&key=AIzaSyAyphWWTQc9W3Z4gWYNkP86WOeswd7mcgA'; // Replace with Ghala's API key later
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      } else {
        print('No results found for query: $query');
      }
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBannerColor,
      appBar: AppBar(
        backgroundColor: kBannerColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          MyIconButton(
            icon: Icons.arrow_forward_ios,
            pressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 15),
        ],
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
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kprimaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 30,
                            height: 2,
                            color: kprimaryColor,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kprimaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 30,
                            height: 2,
                            color: kprimaryColor,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kBannerColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14.0),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          controller: _searchController,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'ابحث عن موقع',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                          ),
                          onSubmitted: (value) async {
                            final location = await _searchLocation(value);
                            if (location != null) {
                              setState(() {
                                _selectedLocation = location;
                                _mapController.animateCamera(
                                  CameraUpdate.newLatLng(location),
                                );
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('لم يتم العثور على الموقع')),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      // Google Maps Container
                      Container(
                        height: 400,
                        width: double.infinity,
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation,
                            zoom: 15,
                          ),
                          onTap: (LatLng location) {
                            setState(() {
                              _selectedLocation = location;
                            });
                          },
                          markers: {
                            Marker(
                              markerId: MarkerId('selected_location'),
                              position:
                                  _selectedLocation, //the only addition to make marker/pin show
                            ),
                          },
                        ),
                      ),

                      const SizedBox(height: 10.0),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kBannerColor),
                          onPressed: () {
                            _saveTruckDetails(context);
                          },
                          child: const Text(
                            'التالي',
                            style: TextStyle(color: Colors.white),
                          ),
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
