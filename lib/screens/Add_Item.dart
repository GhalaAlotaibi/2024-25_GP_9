import 'package:flutter/material.dart';

class AddItemPage extends StatelessWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عنصر جديد'), // "Add New Item" in Arabic
        backgroundColor: const Color(0xFF674188),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20.0), // Space at the top
              
              // Input field for item name
              TextField(
                decoration: InputDecoration(
                  labelText: 'اسم العنصر', // "Item Name" in Arabic
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0), // Spacing between fields

              // Input field for item price
              TextField(
                decoration: InputDecoration(
                  labelText: 'السعر', // "Price" in Arabic
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20.0), // Spacing between fields

              // Input field for image URL
              TextField(
                decoration: InputDecoration(
                  labelText: 'رابط الصورة', // "Image URL" in Arabic
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0), // Spacing between fields

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Action for submitting the new item
                  },
                  child: const Text('إضافة'), // "Add" button text in Arabic
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
