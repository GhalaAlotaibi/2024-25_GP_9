import 'package:flutter/material.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tracki/Utils/constants.dart';
import 'Create_Truck_2.dart';
import 'dart:io';

class CreateTruck1 extends StatefulWidget {
  final String ownerId;

  const CreateTruck1({Key? key, required this.ownerId}) : super(key: key);

  @override
  _CreateTruck1State createState() => _CreateTruck1State();
}

class _CreateTruck1State extends State<CreateTruck1> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  String truckName = '';
  String licenseNo = '';
  String description = '';
  String businessLogoUrl = '';
  String truckImageUrl = '';
  String? openingTime;
  String? closingTime;
  File? businessLogo;
  File? truckImage;

  List<Map<String, String>> categories = [];
  final List<String> timeList = [];
  bool isLogoMissing = false;
  bool isImageMissing = false;

  @override
  void initState() {
    super.initState();
    timeList.addAll(generateTimeList());
    fetchCategories();
  }

//elevated
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
        categories = fetchedCategories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // method to pick and upload image
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

  List<String> generateTimeList() {
    List<String> timeList = [];
    for (int hour = 0; hour < 24; hour++) {
      String time = hour.toString().padLeft(2, '0') + ":00";
      timeList.add(time);
    }
    return timeList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBannerColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF674188),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          MyIconButton(
            icon: Icons.arrow_forward_ios,
            pressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 5),
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
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'إضافة عربة',
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kprimaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 30,
                            height: 2,
                            color: kprimaryColor,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kBannerColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 30,
                            height: 2,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم العربة';
                            }
                            truckName = value;
                            return null;
                          },
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.text,
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

                      const SizedBox(height: 25.0),

                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'رقم الرخصة',
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
                              return 'الرجاء إدخال رقم الرخصة';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              licenseNo = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 25.0),
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
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['id'],
                              child: Text(category['name']!),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 25.0),

//Images => validation required

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
                                    border: Border.all(
                                      color: isLogoMissing
                                          ? const Color.fromARGB(
                                              255, 189, 65, 56)
                                          : Colors.black26,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: businessLogo != null
                                      ? Image.file(businessLogo!,
                                          fit: BoxFit.cover)
                                      : const Icon(
                                          Icons.add_a_photo,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text("صورة الشعار"),
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
                                      color: isImageMissing
                                          ? const Color.fromARGB(
                                              255, 189, 65, 56)
                                          : Colors.black26,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: truckImage != null
                                      ? Image.file(truckImage!,
                                          fit: BoxFit.cover)
                                      : const Icon(
                                          Icons.add_a_photo,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text("صورة العربة"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          maxLength: 140,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
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

                      const SizedBox(height: 25.0),

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
                                //closing hrs

                                Expanded(
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: DropdownButtonFormField<String>(
                                      value: closingTime,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          closingTime = newValue;
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

//opening hrs
                                Expanded(
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: DropdownButtonFormField<String>(
                                      value: openingTime,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          openingTime = newValue;
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

//Operating hrs
                      const SizedBox(height: 30.0),
// Submit Button
                      SizedBox(
                        width: double.infinity,
                        child:
// ElevatedButton with Validation ==> DONE AND CHECKED
                            ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Check if images are missing
                              isLogoMissing = businessLogo == null;
                              isImageMissing = truckImage == null;

                              if (!isLogoMissing &&
                                  !isImageMissing &&
                                  _formKey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      // Navigation logic here
                                      return CreateTruck2(
                                        ownerId: widget.ownerId,
                                        truckName: truckName,
                                        licenseNo: licenseNo,
                                        businessLogo: businessLogoUrl,
                                        truckImage: truckImageUrl,
                                        selectedCategory: selectedCategory!,
                                        description: description,
                                        operatingHours:
                                            '$openingTime-$closingTime',
                                      );
                                    },
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'الرجاء التأكد من أن كل إدخال البيانات كاملة'),
                                  ),
                                );
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBannerColor,
                          ),
                          child: const Text(
                            'التالي',
                            style: TextStyle(color: Colors.white),
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
