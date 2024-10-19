import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//I DONT KNOW IF THIS WORKS OR NOT 
class CreateTruck3 extends StatelessWidget {
  final String ownerId;

  // TextEditingControllers for menu item details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController(); // For image URL input

  CreateTruck3({Key? key, required this.ownerId}) : super(key: key);

  Future<void> _saveMenuItem() async {
    // Check if the input fields are not empty
    if (nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        imageController.text.isNotEmpty) {
      // Reference to Firestore collection
      CollectionReference trucks = FirebaseFirestore.instance.collection('Food_Truck');

      // Create menu item data
      Map<String, dynamic> menuItemData = {
        'name': nameController.text,
        'price': priceController.text,
        'image': imageController.text,
      };

      try {
        // Update the truck document in Firestore by owner ID and add menu item to arrays
        await trucks.doc(ownerId).update({
          'item_names_list': FieldValue.arrayUnion([menuItemData['name']]),
          'item_prices_list': FieldValue.arrayUnion([menuItemData['price']]),
          'item_images_list': FieldValue.arrayUnion([menuItemData['image']]),
        });
        print("Menu item saved successfully");
        // Clear the input fields after saving
        nameController.clear();
        priceController.clear();
        imageController.clear();
      } catch (e) {
        print("Error saving menu item: $e");
      }
    } else {
      print("Please fill in all fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF674188),
        title: const Text('إنشاء عنصر قائمة الطعام'), // "Create Menu Item" title
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Name input field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'اسم العنصر', // Item name
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20.0),

              // Price input field
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'السعر', // Price
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20.0),

              // Image URL input field
              TextField(
                controller: imageController,
                decoration: InputDecoration(
                  labelText: 'رابط الصورة', // Image URL
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20.0),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMenuItem, // Save menu item when pressed
                  child: const Text('إضافة عنصر'), // "Add Item" button text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
