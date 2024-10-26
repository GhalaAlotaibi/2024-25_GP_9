import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/menu_update.dart';
import 'package:tracki/screens/owner_profile.dart';
import 'package:tracki/widgets/my_icon_button.dart';

class TruckDetailsUpdate extends StatefulWidget {
  final String ownerID;

  const TruckDetailsUpdate({Key? key, required this.ownerID}) : super(key: key);

  @override
  _TruckDetailsUpdateState createState() => _TruckDetailsUpdateState();
}

class _TruckDetailsUpdateState extends State<TruckDetailsUpdate> {
  final _formKey = GlobalKey<FormState>();
  String? truckName, truckCategory, truckDescription, logoUrl;
  String? rating;
  int? ratingsCount;
  List<dynamic> itemImagesList = [];
  List<dynamic> itemNamesList = [];
  List<dynamic> itemPricesList = [];
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _getOwnerFoodTruckData(widget.ownerID);
    _fetchCategories();
  }

  Future<void> _getOwnerFoodTruckData(String docId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Food_Truck')
        .doc(docId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        truckName = data['name'] ?? '';
        truckCategory = data['category'] ?? '';
        truckDescription = data['description'] ?? '';
        logoUrl = data['businessLogo'] ?? '';
        rating = data['rating'] ?? '0';
        ratingsCount = data['ratingsCount'] ?? 0;
        itemImagesList = data['item_images_list'] ?? [];
        itemNamesList = data['item_names_list'] ?? [];
        itemPricesList = data['item_prices_list'] ?? [];
      });
    }
  }

  Future<void> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Food-Category').get();

    setState(() {
      categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('truck_logos/${widget.ownerID}.jpg');
      final uploadTask = storageRef.putFile(imageFile);

      await uploadTask.whenComplete(() {});
      final downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        logoUrl = downloadUrl;
      });

      await FirebaseFirestore.instance
          .collection('Food_Truck')
          .doc(widget.ownerID)
          .update({
        'businessLogo': downloadUrl,
      });
    }
  }

  Future<void> _updateTruckDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance
          .collection('Food_Truck')
          .doc(widget.ownerID)
          .update({
        'name': truckName,
        'category': truckCategory,
        'description': truckDescription,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح')));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OwnerProfile(
            ownerID: widget.ownerID,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 105),
            const Text(
              "تحديث بيانات العربة",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
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
      body: truckName == null
          ? const Center(child: CircularProgressIndicator())
          : Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                logoUrl != null ? NetworkImage(logoUrl!) : null,
                            radius: 35,
                            child: logoUrl == null
                                ? const Icon(Icons.add_a_photo)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 8.0),
                              backgroundColor: kbackgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: const BorderSide(
                                    color: Color.fromARGB(116, 0, 0, 0),
                                    width: 1.0),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  size: 21,
                                  Icons.add_a_photo,
                                  color: Color.fromARGB(196, 0, 0, 0),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'اختر صورة جديدة',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Color.fromARGB(196, 0, 0, 0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: truckName,
                        decoration: InputDecoration(
                          labelText: 'تحديث اسم العربة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onSaved: (value) => truckName = value,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'يرجى إدخال اسم العربة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      categories.isNotEmpty
                          ? DropdownButtonFormField<String>(
                              value: truckCategory,
                              decoration: InputDecoration(
                                labelText: 'تحديث تصنيف العربة',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  truckCategory = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى اختيار تصنيف العربة';
                                }
                                return null;
                              },
                            )
                          : const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: truckDescription,
                        decoration: InputDecoration(
                          labelText: 'تحديث وصف العربة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onSaved: (value) => truckDescription = value,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'يرجى إدخال وصف العربة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MenuUpdate(ownerID: widget.ownerID),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(128, 0, 0, 0)),
                            color: kbackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 222, 222, 222)
                                    .withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.dashboard_customize_outlined,
                                  color: Colors.black),
                              SizedBox(width: 10),
                              Text(
                                'تحديـث قـائمة الطعـام',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 240),
                      Center(
                        child: SizedBox(
                          width: 200, // Adjust the width as needed
                          child: ElevatedButton(
                            onPressed: _updateTruckDetails,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: kBannerColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 13, horizontal: 20),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: const Text(
                              "حـفظ التغييرات",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
