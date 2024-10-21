import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditItem extends StatefulWidget {
  final String truckId; // ID of the truck
  final String itemName; // Current name of the item
  final double itemPrice; // Current price of the item
  final String itemImage; // Current image URL of the item
  final int itemIndex; // Index of the item in the list

  const EditItem({
    Key? key,
    required this.truckId,
    required this.itemName,
    required this.itemPrice,
    required this.itemImage,
    required this.itemIndex,
  }) : super(key: key);

  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController imageController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.itemName);
    priceController = TextEditingController(text: widget.itemPrice.toString());
    imageController = TextEditingController(text: widget.itemImage);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    imageController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    CollectionReference trucks =
        FirebaseFirestore.instance.collection('Food_Truck');

    Map<String, dynamic> itemData = {
      'name': nameController.text,
      'price': double.tryParse(priceController.text) ?? 0,
      'image': imageController.text,
    };

    try {
      // Update the item in Firestore arrays
      await trucks.doc(widget.truckId).update({
        'item_names_list': FieldValue.arrayRemove([widget.itemName]),
        'item_prices_list': FieldValue.arrayRemove([widget.itemPrice]),
        'item_images_list': FieldValue.arrayRemove([widget.itemImage]),
      });

      await trucks.doc(widget.truckId).update({
        'item_names_list': FieldValue.arrayUnion([itemData['name']]),
        'item_prices_list': FieldValue.arrayUnion([itemData['price']]),
        'item_images_list': FieldValue.arrayUnion([itemData['image']]),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item updated successfully!')),
      );

      // Navigate back to the truck profile or previous screen
      Navigator.pop(context);
    } catch (e) {
      print("Error updating item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item: $e')),
      );
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
                child: Column(
                  children: [
                    const Text(
                      ' تعديل عنصر', // Title
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
                        decoration: InputDecoration(
                          label: const Text('اسم العنصر'), // Item name
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
                                color: Colors.black12), // Enabled border color
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
                        decoration: InputDecoration(
                          label: const Text('السعر'), // Price
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
                                color: Colors.black12), // Enabled border color
                            borderRadius: BorderRadius.circular(
                                10), // Enabled border radius
                          ),
                          alignLabelWithHint: true, // Align label with hint
                        ),
                        keyboardType:
                            TextInputType.number, // Allow number input
                      ),
                    ),

                    const SizedBox(height: 20.0), // Space after the TextField

                    // Image URL input field
                    Directionality(
                      textDirection:
                          TextDirection.rtl, // Set text direction to RTL
                      child: TextFormField(
                        controller: imageController,
                        decoration: InputDecoration(
                          label: const Text('رابط الصورة'), // Image URL
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
                                color: Colors.black12), // Enabled border color
                            borderRadius: BorderRadius.circular(
                                10), // Enabled border radius
                          ),
                          alignLabelWithHint: true, // Align label with hint
                        ),
                      ),
                    ),

                    const SizedBox(height: 30.0), // Spacing before the button

                    // Update button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateItem, // Update item when pressed
                        child: const Text(
                            'تحديث العنصر'), // "Update Item" button text
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
