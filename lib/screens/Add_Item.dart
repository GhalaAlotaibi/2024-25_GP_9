import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Truck_Profile.dart'; // Import the TruckProfile file

// Add Item screen
class AddItem extends StatelessWidget {
  final String truckId; // Receive truckId from CreateTruck3

  // TextEditingControllers for item details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController =
      TextEditingController(); // For image URL input

  // Create a GlobalKey for the Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AddItem({Key? key, required this.truckId}) : super(key: key);

  Future<void> _saveItem(BuildContext context) async {
    // Validate the form
    if (_formKey.currentState?.validate() ?? false) {
      // Reference to Firestore collection
      CollectionReference trucks =
          FirebaseFirestore.instance.collection('Food_Truck');

      // Create item data
      Map<String, dynamic> itemData = {
        'name': nameController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'image': imageController.text,
      };

      try {
        // Update the truck document by truck ID and add item details to arrays
        await trucks.doc(truckId).update({
          'item_names_list': FieldValue.arrayUnion([itemData['name']]),
          'item_prices_list': FieldValue.arrayUnion([itemData['price']]),
          'item_images_list': FieldValue.arrayUnion([itemData['image']]),
        });

        // Clear the input fields after saving
        nameController.clear();
        priceController.clear();
        imageController.clear();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added successfully!')),
        );

        // Navigate back to the TruckProfile screen after saving
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TruckProfile(
                truckId: truckId), // Navigate to TruckProfile with the truckId
          ),
        );
      } catch (e) {
        print("Error saving item: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF674188),
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
                  key: _formKey, // Assign the GlobalKey
                  child: Column(
                    children: [
                      const Text(
                        'إضافة عنصر للقائمة',
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF674188),
                        ),
                        textAlign: TextAlign.center, // Align text to the center
                      ),
                      const SizedBox(height: 20.0), // Adjusted space

                      // Name input field
                      Directionality(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
                        child: TextFormField(
                          controller: nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم العنصر'; // Error message in Arabic
                            }
                            return null;
                          },
                          textAlign: TextAlign.right, // Align text to the right
                          keyboardType: TextInputType.text, // Allow text input
                          decoration: InputDecoration(
                            label: const Text(
                              'اسم العنصر', // Item name
                              textAlign: TextAlign.center,
                            ),
                            hintText: 'ادخل اسم العنصر', // Hint text
                            hintStyle: const TextStyle(
                                color: Colors.black26), // Hint text style
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black12), // Border color
                              borderRadius:
                                  BorderRadius.circular(10), // Border radius
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color:
                                      Colors.black12), // Enabled border color
                              borderRadius: BorderRadius.circular(
                                  10), // Enabled border radius
                            ),
                            alignLabelWithHint: true, // Align label with hint
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0), // Space after the TextField

                      // Price Input Field
                      Directionality(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
                        child: TextFormField(
                          controller: priceController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال السعر'; // Error message in Arabic
                            }
                            return null;
                          },
                          textAlign: TextAlign.right, // Align text to the right
                          keyboardType:
                              TextInputType.number, // Allow number input
                          decoration: InputDecoration(
                            label: const Text(
                              'السعر', // Price
                              textAlign: TextAlign.center,
                            ),
                            hintText: 'ادخل السعر', // Hint text
                            hintStyle: const TextStyle(
                                color: Colors.black26), // Hint text style
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black12), // Border color
                              borderRadius:
                                  BorderRadius.circular(10), // Border radius
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color:
                                      Colors.black12), // Enabled border color
                              borderRadius: BorderRadius.circular(
                                  10), // Enabled border radius
                            ),
                            alignLabelWithHint: true, // Align label with hint
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0), // Space after the TextField

                      // Image URL input field
                      Directionality(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
                        child: TextFormField(
                          controller: imageController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رابط الصورة'; // Error message in Arabic
                            }
                            return null;
                          },
                          textAlign: TextAlign.right, // Align text to the right
                          keyboardType: TextInputType.text, // Allow text input
                          decoration: InputDecoration(
                            label: const Text(
                              'رابط الصورة', // Image URL
                              textAlign: TextAlign.center,
                            ),
                            hintText: 'ادخل رابط الصورة', // Hint text
                            hintStyle: const TextStyle(
                                color: Colors.black26), // Hint text style
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black12), // Border color
                              borderRadius:
                                  BorderRadius.circular(10), // Border radius
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color:
                                      Colors.black12), // Enabled border color
                              borderRadius: BorderRadius.circular(
                                  10), // Enabled border radius
                            ),
                            alignLabelWithHint: true, // Align label with hint
                          ),
                        ),
                      ),

                      const SizedBox(height: 30.0), // Spacing before the button

                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _saveItem(context), // Save item when pressed
                          child: const Text(
                              'إضافة عنصر'), // "Add Item" button text
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
