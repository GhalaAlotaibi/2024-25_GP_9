import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:tracki/Utils/constants.dart';
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

  // Create a GlobalKey for the Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  Future<void> _saveTruckDetails(BuildContext context) async {
    // Validate the form
    if (_formKey.currentState?.validate() ?? false) {
      // Reference to Firestore collection
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
        'location': locationController.text,
        'rating': '0',
        'ratingsCount': 0, //انا غيرتها ساره غ
        'item_names_list': [], // Initialize with an empty list
        'item_prices_list': [], // Initialize with an empty list
        'item_images_list': [], // Initialize with an empty list
      };

      try {
        // Add the truck to Firestore and get the document reference
        DocumentReference truckRef = await trucks.add(truckData);

        // Get the auto-generated ID
        String truckId = truckRef.id;

        print("Truck details saved successfully with ID: $truckId");

        // Navigate to CreateTruck3 and pass both the ownerId and truckId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateTruck3(
                ownerId: ownerId,
                truckId: truckId), // Pass both ownerId and truckId
          ),
        );
      } catch (e) {
        print("Error saving truck details: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBannerColor,
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
                child: Form(
                  // Wrap with Form
                  key: _formKey, // Assign the GlobalKey
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
                      Directionality(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
                        child: TextFormField(
                          controller: locationController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال الموقع'; // Error message in Arabic
                            }
                            return null;
                          },
                          textAlign: TextAlign.right, // Align text to the right
                          decoration: InputDecoration(
                            label: const Text('أدخل الموقع',
                                textAlign: TextAlign.center),
                            hintText: 'ادخل الموقع',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignLabelWithHint: true,
                          ),
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
                            _saveTruckDetails(
                                context); // Call the function to save details with context
                          },
                          child: const Text('التالي'), // "Next" button text
                          // المفروض هنا ينرسل الطلب للأدمن داشبورد وينتظر اليوزر موافقة
                        ),
                      ),
                      const SizedBox(height: 20.0), // Spacing after the button
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
