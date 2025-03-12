import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleMapFlutter extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String currentOwnerID;
//owner update-location uKIvK7ytL9Mjl6zGf5AIDV6f1fq2
  const GoogleMapFlutter(
      {Key? key,
      required this.latitude,
      required this.longitude,
      required this.currentOwnerID})
      : super(key: key);

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  late LatLng _selectedLocation;
  late GoogleMapController _mapController;
  File? _licenseFile;
  String? _licenseFileUrl;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.latitude, widget.longitude);
  }

  Future<void> _pickAndUploadLicenseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('Updated_location/${DateTime.now().millisecondsSinceEpoch}');
        await storageRef.putFile(file);
        final fileUrl = await storageRef.getDownloadURL();

        setState(() {
          _licenseFile = file;
          _licenseFileUrl = fileUrl;
        });
      } catch (e) {
        print('Error uploading file: $e');
      }
    }
  }

  Future<void> _showUpdateLocationDialog() async {
    LatLng _newLocation = _selectedLocation;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("تحديث موقع العربة"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("يرجى تحميل ملف رخصة تغيير الموقع"),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickAndUploadLicenseFile,
                    icon: Icon(Icons.upload_file),
                    label: Text(_licenseFile == null
                        ? 'تحميل ملف الرخصة'
                        : 'تم تحميل الملف'),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 300,
                    width: double.infinity,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _newLocation,
                        zoom: 14,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      onTap: (LatLng tappedPoint) {
                        setDialogState(() {
                          _newLocation =
                              tappedPoint; // Move marker to tap location
                        });
                      },
                      markers: {
                        Marker(
                          markerId: MarkerId('updated_location'),
                          position: _newLocation,
                        ),
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("إلغاء"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedLocation = _newLocation; // Save the new location
                    });
                    Navigator.pop(context);
                    _submitLocationUpdateRequest();
                  },
                  child: Text("حفظ الموقع"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _navigateToUpdateMap() async {
    LatLng? newLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UpdateTruckLocationMap(initialLocation: _selectedLocation),
      ),
    );
    if (newLocation != null) {
      setState(() {
        _selectedLocation = newLocation;
      });
      _submitLocationUpdateRequest();
    }
  }

  Future<void> _submitLocationUpdateRequest() async {
    if (_licenseFileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى تحميل ملف رخصة الموقع")),
      );
      return;
    }

    try {
      // Fetch food truck document
      DocumentSnapshot foodTruckDoc = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .doc(widget.currentOwnerID)
          .get();

      if (!foodTruckDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("لم يتم العثور على العربة في قاعدة البيانات")),
        );
        return;
      }

      // Extract the correct ownerID from Food_Truck
      String ownerID = foodTruckDoc.get('ownerID');

      // Save the correct ownerID in Location_Update
      await FirebaseFirestore.instance.collection('Location_Update').add({
        'ownerID': ownerID, // ✅ Now storing the actual ownerID
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
        'locationUpdateFile': _licenseFileUrl,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "تم إرسال طلب تحديث الموقع بنجاح، سيتم مراجعة طلبك والتواصل معك عبر البريد الإلكتروني قريبًا."),
        ),
      );
    } catch (e) {
      print("Error submitting location update request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: MarkerId('current_location'),
                position: _selectedLocation,
              ),
            },
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 75,
            child: ElevatedButton(
              onPressed: _showUpdateLocationDialog,
              child: Text("تحديث موقع العربة"),
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateTruckLocationMap extends StatefulWidget {
  final LatLng initialLocation;

  const UpdateTruckLocationMap({Key? key, required this.initialLocation})
      : super(key: key);

  @override
  State<UpdateTruckLocationMap> createState() => _UpdateTruckLocationMapState();
}

class _UpdateTruckLocationMapState extends State<UpdateTruckLocationMap> {
  late LatLng _newLocation;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _newLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("حدد الموقع الجديد")),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _newLocation,
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: MarkerId('new_location'),
                position: _newLocation,
                draggable: true,
                onDragEnd: (newPosition) {
                  setState(() {
                    _newLocation = newPosition;
                  });
                },
              ),
            },
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 75,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _newLocation);
              },
              child: Text("تأكيد الموقع الجديد"),
            ),
          ),
        ],
      ),
    );
  }
}
