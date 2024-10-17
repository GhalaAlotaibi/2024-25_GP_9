import 'package:flutter/material.dart';
import 'Add_Item.dart'; 
import 'Edit_Item.dart'; 

class CreateTruck3 extends StatelessWidget {
  // Sample data for menu items
  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'برغر لحم', // Beef Burger
      'price': '20 ريال', // 20 SAR
      'image': 'assets/images/logo_Tracki.png', // Local image for Beef Burger
    },
    {
      'name': 'TTEESSTTYYبيتزا مارجريتا', // Margherita Pizza (with typo)
      'price': '30 ريال', // 30 SAR
      'image': 'assets/images/logo_Tracki.png', // Replace with your image URL
    },
  ];

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
                    const SizedBox(height: 20.0), // Adjusted space
                    const Text(
                      'إنشاء قائمة الطعام',
                      style: TextStyle(
                        fontSize: 27.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF674188),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30.0), // Spacing before menu items

                    // Display the menu items
                    Column(
                      children: List.generate(2, (index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.asset(
                                    menuItems[index]['image'], // Use Image.asset for local images
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 15), // Space between image and text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        menuItems[index]['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        menuItems[index]['price'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Edit button
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const EditItemPage(), // Navigate to Edit_Item.dart
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20.0), // Spacing after the menu items

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Action for confirming the creation of the truck goes here
                        },
                        child: const Text('تأكيد'), // "Confirm" button text
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

      // Add button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddItemPage(), // Navigate to Add_Item.dart
            ),
          );
        },
        child: const Icon(Icons.add), // Plus icon
        backgroundColor: const Color(0xFF674188),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}