import 'package:flutter/material.dart';

class EditItemPage extends StatelessWidget {
  const EditItemPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data to pre-fill the form
    final String itemName = 'برغر لحم'; // Current item name
    final String itemPrice = '20 ريال'; // Current item price
    final String itemImage = 'assets/images/logo_Tracki.png'; // Current image URL

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل العنصر'), // "Edit Item" in Arabic
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
                controller: TextEditingController(text: itemName),
                decoration: InputDecoration(
                  labelText: 'اسم العنصر', // "Item Name" in Arabic
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0), // Spacing between fields

              // Input field for item price
              TextField(
                controller: TextEditingController(text: itemPrice),
                decoration: InputDecoration(
                  labelText: 'السعر', // "Price" in Arabic
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20.0), // Spacing between fields

              // Input field for image URL
              TextField(
                controller: TextEditingController(text: itemImage),
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
                    // Action for saving the edited item
                  },
                  child: const Text('تأكيد'), // "Confirm" button text in Arabic
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
