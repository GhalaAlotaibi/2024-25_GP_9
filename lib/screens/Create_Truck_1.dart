import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:tracki/Utils/constants.dart';
import 'Create_Truck_2.dart';

class CreateTruck1 extends StatefulWidget {
  final String ownerId; // Add this field to capture OwnerId

  const CreateTruck1({Key? key, required this.ownerId}) : super(key: key);

  @override
  _CreateTruck1State createState() => _CreateTruck1State();
}

class _CreateTruck1State extends State<CreateTruck1> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  String? selectedCategory; // Variable to hold the selected category
  String truckName = ''; // To hold truck name
  String description = ''; // To hold truck description
  String businessLogo = ''; // To hold business logo URL
  String truckImage = ''; // To hold truck image URL
  String? openingTime;
  String? closingTime;

  // List of truck categories
  List<String> categories = []; // Initialize as an empty list

  // Generate a list of times in 24-hour format
  List<String> generateTimeList() {
    List<String> timeList = [];
    for (int hour = 0; hour < 24; hour++) {
      String time =
          hour.toString().padLeft(2, '0') + ":00"; // Format as "HH:MM"
      timeList.add(time);
    }
    return timeList;
  }

  final List<String> timeList = []; // Generate time list

  @override
  void initState() {
    super.initState();
    timeList.addAll(generateTimeList());
    fetchCategories(); // Call the fetch function
  }

  // Fetch categories from Firestore
  Future<void> fetchCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Food-Category').get();

      List<String> fetchedCategories = snapshot.docs
          .map((doc) => doc['name'] as String) // Get the 'name' field
          .toList();

      setState(() {
        categories = fetchedCategories; // Update the categories list
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBannerColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF674188), // App bar color
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
              padding: const EdgeInsets.fromLTRB(
                  25.0, 20.0, 25.0, 20.0), // Add padding around the body
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey, // Use the form key for validation
                  child: Column(
                    children: [
                      const Text(
                        'إضافة عربة',
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF674188),
                        ),
                        textAlign: TextAlign.center, // Align text to the center
                      ),
                      const SizedBox(height: 20.0), // Adjusted space

                      // Truck Name Input Field
                      Directionality(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم العربة'; // Error message in Arabic
                            }
                            truckName = value; // Save the truck name
                            return null;
                          },
                          textAlign: TextAlign.right, // Align text to the right
                          keyboardType: TextInputType.text, // Allow text input
                          decoration: InputDecoration(
                            label: const Text('اسم العربة',
                                textAlign: TextAlign.center),
                            hintText: 'ادخل اسم العربة',
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

                      const SizedBox(
                          height: 25.0), // Spacing after the input field

                      // Business Logo Input Field
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رابط الشعار';
                            }
                            businessLogo = value;
                            return null;
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            label: const Text('رابط الشعار',
                                textAlign: TextAlign.center),
                            hintText: 'ادخل رابط الشعار',
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

                      const SizedBox(
                          height: 25.0), // Spacing after the input field

                      // Truck Image Input Field
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رابط صورة العربة';
                            }
                            truckImage = value;
                            return null;
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            label: const Text('رابط صورة العربة',
                                textAlign: TextAlign.center),
                            hintText: 'ادخل رابط صورة العربة',
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

                      const SizedBox(
                          height: 25.0), // Spacing after the input field

                      // Truck Category Dropdown
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          validator: (value) {
                            if (value == null) {
                              return 'الرجاء اختيار تصنيف العربة';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('تصنيف العربة',
                                textAlign: TextAlign.right),
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
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                          items: categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 25.0),
// Truck Description Input Field
                      Directionality(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
                        child: TextFormField(
                          maxLength: 140,
                          textAlign: TextAlign.right, // Align text to the right
                          keyboardType:
                              TextInputType.multiline, // Allow multiline input
                          maxLines: null, // Allow unlimited lines
                          decoration: InputDecoration(
                            labelText: 'وصف للعربة',
                            hintText: 'ادخل وصفًا للعربة',
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
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال وصف للعربة';
                            }
                            description = value;
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(
                          height: 25.0), // Spacing after the input field

                      // Operating Hours Input Fields
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: openingTime,
                                validator: (value) {
                                  if (value == null) {
                                    return 'الرجاء اختيار ساعة الافتتاح'; // Error message in Arabic
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  label: const Text('اختر ساعة الافتتاح',
                                      textAlign: TextAlign
                                          .right), // Right-aligned label
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
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    openingTime =
                                        newValue; // Update opening time
                                  });
                                },
                                items: timeList.map((String time) {
                                  return DropdownMenuItem<String>(
                                    value: time,
                                    child: Text(time), // Display time
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(
                                width: 15), // Spacing between dropdowns
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: closingTime,
                                validator: (value) {
                                  if (value == null) {
                                    return 'الرجاء اختيار ساعة الإغلاق'; // Error message in Arabic
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  label: const Text('اختر ساعة الإغلاق',
                                      textAlign: TextAlign
                                          .right), // Right-aligned label
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
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    closingTime =
                                        newValue; // Update closing time
                                  });
                                },
                                items: timeList.map((String time) {
                                  return DropdownMenuItem<String>(
                                    value: time,
                                    child: Text(time), // Display time
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30.0), // Spacing before button
// Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, navigate to the next page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    // Combine opening and closing times outside the widget parameters
                                    String operatingHours =
                                        '$openingTime-$closingTime';

                                    return CreateTruck2(
                                      ownerId: widget
                                          .ownerId, // Pass the owner ID to the next page
                                      truckName: truckName, // Pass truck name
                                      businessLogo:
                                          businessLogo, // Pass business logo
                                      truckImage:
                                          truckImage, // Pass truck image
                                      selectedCategory:
                                          selectedCategory!, // Pass selected category
                                      description:
                                          description, // Pass truck description
                                      operatingHours:
                                          operatingHours, // Pass combined operating hours
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          child: Text(
                            'التالي',
                            style: TextStyle(
                              color: Color(0xFF674188),
                            ),
                          ),
                        ),
                      ),
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
