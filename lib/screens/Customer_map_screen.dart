import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerMapScreen extends StatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends State<CustomerMapScreen> {
  LatLng myCurrentLocation =
      const LatLng(24.7136, 46.6753); // Default Riyadh location
  GoogleMapController? googleMapController;
  final Set<Marker> markers = {}; // Holds all markers
  final List<Map<String, dynamic>> foodTrucks =
      []; // Truck data for bottom sheet
  int? selectedTruckIndex; // Tracks the selected truck index

  @override
  void initState() {
    super.initState();
    fetchFoodTruckLocations();
  }

  Future<void> fetchFoodTruckLocations() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Food_Truck').get();

      for (var doc in querySnapshot.docs) {
        final statusId = doc['statusId']; // Get the statusId field
        final location = doc['location'] as String? ?? '';
        final name = doc['name'] as String? ?? 'Unknown Truck';
        final businessLogo =
            doc['businessLogo'] as String? ?? 'https://via.placeholder.com/150';
        final operatingHours =
            doc['operatingHours'] as String? ?? 'Not Available';

        // Fetch the request document using the statusId
        DocumentSnapshot requestDoc = await FirebaseFirestore.instance
            .collection('Request')
            .doc(statusId)
            .get();

        final status = requestDoc['status'] as String? ??
            'pending'; // Default to pending if no status is found

        // Proceed only if the status is "accepted"
        if (status == 'accepted' && location.contains(',')) {
          final latLng = location.split(',');
          if (latLng.length == 2) {
            final latitude = double.tryParse(latLng[0]);
            final longitude = double.tryParse(latLng[1]);

            if (latitude != null && longitude != null) {
              final position = LatLng(latitude, longitude);

              setState(() {
                markers.add(
                  Marker(
                    markerId: MarkerId(doc.id),
                    position: position,
                    infoWindow: InfoWindow(title: name),
                    onTap: () {
                      _onMarkerTap(position);
                    },
                  ),
                );

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

  void _onMarkerTap(LatLng position) {
    googleMapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
    setState(() {
      selectedTruckIndex = foodTrucks.indexWhere(
        (truck) => truck['location'] == position,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            markers: markers,
            onMapCreated: (controller) {
              googleMapController = controller;
              googleMapController?.animateCamera(
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
              child: Directionality(
                // Add Directionality for RTL
                textDirection: TextDirection.rtl,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: foodTrucks.length,
                  itemBuilder: (context, index) {
                    final foodTruck = foodTrucks[index];
                    final isSelected = selectedTruckIndex == index;

                    return GestureDetector(
                      onTap: () {
                        _onTruckCardTap(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 260,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE0E0E0)
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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          foodTruck['businessLogo']),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  foodTruck['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'ساعات العمل: ${foodTruck['operatingHours']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 4),
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
          ),
        ],
      ),
    );
  }

  void _onTruckCardTap(int index) {
    final selectedTruck = foodTrucks[index];
    googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        selectedTruck['location'],
        14,
      ),
    );
    setState(() {
      selectedTruckIndex = index;
    });
  }
}
