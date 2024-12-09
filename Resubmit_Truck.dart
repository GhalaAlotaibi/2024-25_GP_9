import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'welcome_screen.dart';

class Resubmit_Truck extends StatefulWidget {
  final String ownerID;

  Resubmit_Truck({required this.ownerID});

  @override
  _Resubmit_TruckState createState() => _Resubmit_TruckState();
}

class _Resubmit_TruckState extends State<Resubmit_Truck> {
  String name = '';
  String licenseNo = '';
  String categoryId2 = '';
  String businessLogo2 = '';
  String truckImage2 = '';
  String description = '';

  String? openingTime;
  String? closingTime;

  String operatingHours2 = '';
  String openingTime2 = "10:00"; // Default opening time
  String closingTime2 = "20:00"; // Default closing time

  String location = '';

  //////////////////user new inputs
  String? selectedCategory;
  String truckName = '';
  //String licenseNo = '';
  //String description = '';
  String businessLogoUrl = '';
  String truckImageUrl = '';
  //String? openingTime;
  //String? closingTime;
  File? businessLogo;
  File? truckImage;

  List<Map<String, String>> categories = [];
  final List<String> timeList = []; //operatingHrs

  @override
  void initState() {
    super.initState();
    timeList.addAll(generateTimeList());
    fetchTruckDetails();
    fetchCategories();
  }

  // fetch truck data *********************************************************
  void fetchTruckDetails() async {
    try {
      QuerySnapshot foodTruckQuery = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .where('ownerID', isEqualTo: widget.ownerID)
          .get();

      if (foodTruckQuery.docs.isNotEmpty) {
        var foodTruckDoc = foodTruckQuery.docs[0];

        setState(() {
          name = foodTruckDoc['name'] ?? '';
          licenseNo = foodTruckDoc['licenseNo'] ?? '';
          categoryId2 = foodTruckDoc['categoryId'] ?? '';
          businessLogo2 = foodTruckDoc['businessLogo'] ?? '';
          truckImage2 = foodTruckDoc['truckImage'] ?? '';
          description = foodTruckDoc['description'] ?? '';
          operatingHours2 = foodTruckDoc['operatingHours'] ?? '';
          location = foodTruckDoc['location'] ?? '';
          selectedCategory = categoryId2; // Set the default selected category

          // Split the operatingHours2 to set openingTime2 and closingTime2
          if (operatingHours2.isNotEmpty && operatingHours2.contains('-')) {
            List<String> hours = operatingHours2.split('-');
            openingTime2 = hours[0];
            closingTime2 = hours[1];
          } else {
            openingTime2 = "00:00"; // Default opening time
            closingTime2 = "00:00"; // Default closing time
          }
        });
      } else {
        print('لاتوجد عربة تحت هذا المعرف');
      }
    } catch (e) {
      print(':خطأ في إستعادة البيانات $e');
    }
  }

  //fetch categories ***********************************************************
  Future<void> fetchCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Food-Category').get();

      List<Map<String, String>> fetchedCategories = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] as String,
        };
      }).toList();

      setState(() {
        categories =
            fetchedCategories; // Make sure categories is a List<Map<String, String>>
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

// Update Food Truck **********************************************************
  void updateTruckDetails() async {
    String operatingHours = '$openingTime-$closingTime';
    try {
      QuerySnapshot foodTruckQuery = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .where('ownerID', isEqualTo: widget.ownerID)
          .get();

      if (foodTruckQuery.docs.isNotEmpty) {
        String truckId = foodTruckQuery.docs[0].id;

        // Update the Food_Truck document
        await FirebaseFirestore.instance
            .collection('Food_Truck')
            .doc(truckId)
            .update({
          'name': name,
          'licenseNo': licenseNo,
          'categoryId': selectedCategory,
          'businessLogo': businessLogoUrl,
          'truckImage': truckImageUrl,
          'description': description,
          'operatingHours': operatingHours,
          'location': location,
        });

        await FirebaseFirestore.instance
            .collection('Request')
            .where('foodTruckId', isEqualTo: truckId)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            String requestId = querySnapshot.docs[0].id;
            FirebaseFirestore.instance
                .collection('Request')
                .doc(requestId)
                .update({
              'status': 'pending',
              'message': 'طلب إضافة عربة جديد',
            });
          }
        }).catchError((error) {
          print(':خطأ في تحديث الطلب $error');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('تم تحديث بيانات العربة وتم إرسال الطلب بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على العربة')),
        );
      }
    } catch (e) {
      print('Error updating truck: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحديث البيانات')),
      );
    }
  }

// Method to pick and upload image**********************************************
  Future<void> _pickAndUploadImage({required bool isBusinessLogo}) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/${DateTime.now().millisecondsSinceEpoch}');
        await storageRef.putFile(imageFile);
        final imageUrl = await storageRef.getDownloadURL();

        setState(() {
          if (isBusinessLogo) {
            businessLogo = imageFile;
            businessLogoUrl = imageUrl;
          } else {
            truckImage = imageFile;
            truckImageUrl = imageUrl;
          }
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  //operatingHrs method*********************************************************
  List<String> generateTimeList() {
    List<String> timeList = [];
    for (int hour = 0; hour < 24; hour++) {
      String time = hour.toString().padLeft(2, '0') + ":00";
      timeList.add(time);
    }
    return timeList;
  }

  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF674188),
      appBar: AppBar(
        backgroundColor: Color(0xFF674188),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          MyIconButton(
            icon: Icons.arrow_forward_ios,
            pressed: () {
              Navigator.pop(context); // This will return to the previous page
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(height: 5),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'إعادة تقديم طلب عربة',
                      style: TextStyle(
                        fontSize: 27.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF674188),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20.0),

//Name
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: TextEditingController(
                            text: name), // Use truckName here.
                        decoration: InputDecoration(
                          labelText: 'اسم العربة',
                          hintText: 'ادخل اسم العربة',
                          hintStyle: TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          name = value; // Update truckName when the user types.
                        },
                      ),
                    ),

                    SizedBox(height: 25.0),

//licenseNo
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: TextEditingController(text: licenseNo),
                        decoration: InputDecoration(
                          labelText: 'رقم الرخصة',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          licenseNo =
                              value; // Update truckName when the user types.
                        },
                      ),
                    ),

                    SizedBox(height: 25.0),

//category
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
                            selectedCategory = newValue;
                          });
                        },
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'], // Use the categoryId here
                            child: Text(
                                category['name']!), // Display category name
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: 25.0),

//Images
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: () =>
                                  _pickAndUploadImage(isBusinessLogo: true),
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: businessLogo !=
                                        null // Check if the user picked a new image
                                    ? Image.file(businessLogo!,
                                        fit: BoxFit.cover)
                                    : (businessLogo2
                                            .isNotEmpty // Show fetched image if available
                                        ? Image.network(businessLogo2,
                                            fit: BoxFit.cover)
                                        : const Icon(
                                            // Show the icon if no image is available
                                            Icons.add_a_photo,
                                            color: Colors.grey,
                                            size: 30,
                                          )),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text("اختيار الشعار"),
                          ],
                        ),
                        Column(
                          children: [
                            InkWell(
                              onTap: () =>
                                  _pickAndUploadImage(isBusinessLogo: false),
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black26), // Add border
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: truckImage !=
                                        null // Check if the user picked a new image
                                    ? Image.file(truckImage!, fit: BoxFit.cover)
                                    : (truckImage2
                                            .isNotEmpty // Show fetched image if available
                                        ? Image.network(truckImage2,
                                            fit: BoxFit.cover)
                                        : const Icon(
                                            // Show the icon if no image is available
                                            Icons.add_a_photo,
                                            color: Colors.grey,
                                            size: 30,
                                          )),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text("اختيار صورة العربة"),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 25.0),

//description
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: TextEditingController(text: description),
                        decoration: InputDecoration(
                          labelText: 'وصف العربة',
                          hintText: 'ادخل وصف العربة',
                          hintStyle: TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          description = value;
                        },
                      ),
                    ),

                    SizedBox(height: 25.0),

//operating hrs
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'اختر أوقات العمل',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Closing hours dropdown
                              Expanded(
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: DropdownButtonFormField<String>(
                                    value: closingTime2,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'الرجاء الإختيار';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'إلى',
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        closingTime = newValue ??
                                            closingTime2; // Keep the default if not selected
                                      });
                                    },
                                    items: timeList.map((String time) {
                                      return DropdownMenuItem<String>(
                                        value: time,
                                        child: Text(time,
                                            textAlign: TextAlign.right),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 15),

                              // Opening hours dropdown
                              Expanded(
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: DropdownButtonFormField<String>(
                                    value: openingTime2,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'الرجاء الإختيار';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'من',
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        openingTime = newValue ?? openingTime2;
                                      });
                                    },
                                    items: timeList.map((String time) {
                                      return DropdownMenuItem<String>(
                                        value: time,
                                        child: Text(time,
                                            textAlign: TextAlign.right),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

//Operating hrs ENDS

                    SizedBox(height: 25.0),

//location
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: TextEditingController(text: location),
                        decoration: InputDecoration(
                          labelText: 'موقع العربة',
                          hintText: 'ادخل موقع العربة',
                          hintStyle: TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          location = value;
                        },
                      ),
                    ),

                    SizedBox(height: 25.0),

///////////////////////////////////
// Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          updateTruckDetails();

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'تأكيد',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Color(0xFF674188),
                                    fontSize: 18,
                                  ),
                                ),
                                content: Text(
                                  '!تم إرسال الطلب بنجاح',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Color(0xFF674188),
                                    fontSize: 25,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WelcomeScreen()),
                                      );
                                    },
                                    child: Text(
                                      'موافق',
                                      style: TextStyle(
                                        color: Color(0xFF674188),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          'إرسال الطلب',
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
        ],
      ),
    );
  }
}
