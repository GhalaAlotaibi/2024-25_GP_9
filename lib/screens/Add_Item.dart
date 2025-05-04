import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'Truck_Profile.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddItem extends StatefulWidget {
  final String truckId;

  const AddItem({Key? key, required this.truckId}) : super(key: key);

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState?.validate() ?? false && _selectedImage != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String fileName =
            'images/${widget.truckId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(_selectedImage!);
        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();

        CollectionReference trucks =
            FirebaseFirestore.instance.collection('Food_Truck');
        DocumentSnapshot truckSnapshot = await trucks.doc(widget.truckId).get();
        if (!truckSnapshot.exists) throw 'Truck not found!';

        List<dynamic> nameList =
            List.from(truckSnapshot['item_names_list'] ?? []);
        List<dynamic> priceList =
            List.from(truckSnapshot['item_prices_list'] ?? []);
        List<dynamic> imageList =
            List.from(truckSnapshot['item_images_list'] ?? []);

        nameList.add(nameController.text);
        priceList.add(double.tryParse(priceController.text) ?? 0.0);
        imageList.add(imageUrl);

        await trucks.doc(widget.truckId).update({
          'item_names_list': nameList,
          'item_prices_list': priceList,
          'item_images_list': imageList,
        });

        nameController.clear();
        priceController.clear();
        setState(() {
          _selectedImage = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت الإضافة بنجاح!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        print("Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشلت الإضافة: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال جميع البيانات واختيار صورة')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBannerColor,
      appBar: AppBar(
        backgroundColor: kBannerColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const SizedBox(width: 15),
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
                        'إضافة صنف للقائمة',
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF674188),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: nameController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'الرجاء إدخال اسم الصنف'
                              : null,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            label: const Text('اسم الصنف'),
                            hintText: 'ادخل اسم الصنف',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: priceController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'الرجاء إدخال السعر'
                              : null,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            label: const Text('السعر'),
                            hintText: 'ادخل السعر',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey,
                                  size: 50,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kBannerColor),
                          onPressed: _isLoading ? null : _saveItem,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  'إضافة صنف',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
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
