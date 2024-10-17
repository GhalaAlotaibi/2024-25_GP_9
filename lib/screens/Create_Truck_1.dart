import 'package:flutter/material.dart';
import 'Create_Truck_2.dart';

class CreateTruck1 extends StatefulWidget {
  const CreateTruck1({Key? key}) : super(key: key);

  @override
  _CreateTruck1State createState() => _CreateTruck1State();
}

class _CreateTruck1State extends State<CreateTruck1> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  String? selectedCategory; // Variable to hold the selected category

  // List of truck categories
  final List<String> categories = [
    'طعام',
    'مشروبات',
    'حلويات',
    'مأكولات سريعة',
  ];

  // Generate a list of times in 24-hour format
  List<String> generateTimeList() {
    List<String> timeList = [];
    for (int hour = 0; hour < 24; hour++) {
      String time = hour.toString().padLeft(2, '0') + ":00"; // Format as "HH:MM"
      timeList.add(time);
    }
    return timeList;
  }

  // Properties to hold selected opening and closing times
  String? openingTime; 
  String? closingTime; 
  final List<String> timeList = []; // Generate time list

  @override
  void initState() {
    super.initState();
    timeList.addAll(generateTimeList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0), // Add padding around the body
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
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم العربة'; // Error message in Arabic
                          }
                          return null;
                        },
                        textAlign: TextAlign.right, // Align text to the right
                        decoration: InputDecoration(
                          label: const Text('اسم العربة', textAlign: TextAlign.center), // Right-aligned label
                          hintText: 'ادخل اسم العربة',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignLabelWithHint: true, // Align label with hint
                        ),
                      ),
                      const SizedBox(height: 25.0), // Spacing after the input field

                      // Truck Category Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        validator: (value) {
                          if (value == null) {
                            return 'الرجاء اختيار تصنيف العربة'; // Error message in Arabic
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('تصنيف العربة', textAlign: TextAlign.right), // Right-aligned label
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue; // Update selected category
                          });
                        },
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category), // Display category
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 25.0), // Spacing after the dropdown

                      // Truck Description Input Field
                      TextFormField(
                        maxLength: 140, // 140 characters
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'وصف للعربة',
                          hintText: 'ادخل وصفًا للعربة',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال وصف للعربة'; // Error message in Arabic
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25.0), // Spacing after the input field

                      // Operating Hours Input Fields
                      Row(
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
                                label: const Text('اختر ساعة الافتتاح', textAlign: TextAlign.right),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  openingTime = newValue; // Update selected opening time
                                });
                              },
                              items: timeList.map((String time) {
                                return DropdownMenuItem<String>(
                                  value: time,
                                  child: Text(time), // Display formatted time
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 10), // Space between dropdowns
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
                                label: const Text('اختر ساعة الإغلاق', textAlign: TextAlign.right),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  closingTime = newValue; // Update selected closing time
                                });
                              },
                              items: timeList.map((String time) {
                                return DropdownMenuItem<String>(
                                  value: time,
                                  child: Text(time), // Display formatted time
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25.0), // Spacing before the button

                      // Button for registration
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreateTruck2()), // Replace NewScreen with your actual screen widget
                                );
                            }
                          },
                          child: const Text('التالي '), // Button text in Arabic
                        ),
                      ),
                      const SizedBox(height: 30.0), // Spacing after the button
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