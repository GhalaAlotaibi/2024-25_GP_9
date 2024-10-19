import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'Create_Truck_3.dart';

class CreateTruck2 extends StatelessWidget {
  final String ownerId; // Capture the owner ID
  final String truckName; // Truck name
  final String businessLogo; // Business logo URL
  final String truckImage; // Truck image URL
  final String selectedCategory; // Selected category
  final String description; // Description
  final String operatingHours; // Combined operating hours

  // TextEditingController for the location input
  final TextEditingController locationController = TextEditingController();

  CreateTruck2({
    Key? key,
    required this.ownerId,
    required this.truckName,
    required this.businessLogo,
    required this.truckImage,
    required this.selectedCategory,
    required this.description,
    required this.operatingHours, // Pass combined operating hours
  }) : super(key: key);

  Future<void> _saveTruckDetails() async {
    // Reference to Firestore collection
    CollectionReference trucks =
        FirebaseFirestore.instance.collection('Food_Truck');

    // Create truck data to save
    Map<String, dynamic> truckData = {
      'name': truckName,
      'businessLogo': businessLogo,
      'truckImage': truckImage,
      'category': selectedCategory, // Use the selected category
      'description': description,
      'operatingHours': operatingHours, // Save combined operating hours
      'ownerID': ownerId, // Associate with owner ID
      'location': locationController.text, // Save the location string
      'rating': '0', // Initial rating ((SET AS A STRING ACCORDING TO SARA GMS))
      'ratingsCount':
          '0', // Initial ratings count ((SET AS A STRING ACCORDING TO SARA GMS))
    };

    try {
      // Add the truck to Firestore
      await trucks.add(truckData);
      print("Truck details saved successfully");
    } catch (e) {
      print("Error saving truck details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF674188), // Same app bar color
      ),
      body: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 5), // Reduced height
          ),
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
                child: Column(
                  children: [
                    const Text(
                      'تحديد الموقع',
                      style: TextStyle(
                        fontSize: 27.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF674188),
                      ),
                      textAlign: TextAlign.center, // Align text to the center
                    ),
                    const SizedBox(height: 20.0), // Adjusted space

                    // Location input field
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'أدخل الموقع', // Enter location
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200], // Light background color
                      ),
                    ),

                    const SizedBox(height: 20.0), // Space after the TextField

                    // Google API Container (Placeholder)
                    Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 247, 134, 158),
                        border: Border.all(
                          color: const Color.fromARGB(255, 231, 233, 235),
                          width: 2.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Here Will Be The Location API',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center, // Center align text
                      ),
                    ),

                    const SizedBox(height: 30.0), // Spacing before the button

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _saveTruckDetails(); // Call the function to save details
                          // Navigate to CreateTruck3 when pressed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                             builder: (context) => CreateTruck3(ownerId: ownerId), // Pass ownerId,
                             // we might consider passing a foodtruckID I will check with sara
                            ),
                          );
                        },
                        child: const Text('التالي'), // Placeholder button text
                      ),
                    ),
                    const SizedBox(height: 20.0), // Spacing after the button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
