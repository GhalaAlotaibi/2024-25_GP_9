import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerMapScreen extends StatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends State<CustomerMapScreen> {
  LatLng myCurrentLocation = const LatLng(24.7136, 46.6753); // Default location
  late GoogleMapController googleMapController;
  Set<Marker> markers = {}; // Holds all markers
  List<Map<String, dynamic>> foodTrucks = []; // Truck data for bottom sheet
  int? selectedTruckIndex; // Tracks the selected truck index

  @override
  void initState() {
    super.initState();
    fetchFoodTruckLocations(); // Fetch food truck locations on initialization
  }

  Future<void> fetchFoodTruckLocations() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Food_Truck').get();

      for (var doc in querySnapshot.docs) {
        String location = doc['location'] ?? ''; // Default to empty if null
        String name = doc['name'] ?? 'Unknown Truck'; // Default name
        String businessLogo = doc['businessLogo'] ??
            'https://via.placeholder.com/150'; // Default logo
        String operatingHours =
            doc['operatingHours'] ?? 'Not Available'; // Default hours

        if (location.contains(',')) {
          List<String> latLng = location.split(',');

          if (latLng.length == 2) {
            double? latitude = double.tryParse(latLng[0]);
            double? longitude = double.tryParse(latLng[1]);

            if (latitude != null && longitude != null) {
              LatLng position = LatLng(latitude, longitude);
              Marker marker = Marker(
                markerId: MarkerId(doc.id),
                position: position,
                infoWindow: InfoWindow(title: name),
                onTap: () {
                  googleMapController.animateCamera(
                    CameraUpdate.newLatLngZoom(position, 16),
                  );
                  setState(() {
                    selectedTruckIndex = foodTrucks.indexWhere(
                      (truck) => truck['location'] == position,
                    );
                  });
                },
              );

              setState(() {
                markers.add(marker); // Add marker to the map
                foodTrucks.add({
                  'name': name,
                  'businessLogo': businessLogo,
                  'operatingHours': operatingHours,
                  'location': position,
                  'rating': 4.5, // Static rating
                });
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
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
              googleMapController.animateCamera(
                CameraUpdate.newLatLng(myCurrentLocation),
              );
            },
            initialCameraPosition: CameraPosition(
              target: myCurrentLocation,
              zoom: 11,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: foodTrucks.length,
                itemBuilder: (context, index) {
                  final foodTruck = foodTrucks[index];
                  final isSelected = selectedTruckIndex == index;

                  return GestureDetector(
                    onTap: () {
                      googleMapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          foodTruck['location'],
                          14,
                        ),
                      );
                      setState(() {
                        selectedTruckIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 260,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE0E0E0) // Highlight color
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  foodTruck['businessLogo'],
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  foodTruck['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'ساعات العمل: ${foodTruck['operatingHours']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text(
                                foodTruck['rating'].toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
