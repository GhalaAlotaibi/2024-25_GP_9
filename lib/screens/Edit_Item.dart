import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/my_icon_button.dart';

class EditItem extends StatefulWidget {
  final String truckId;
  final String itemName;
  final double itemPrice;
  final String itemImage;
  final int itemIndex;

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
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.itemName);
    priceController = TextEditingController(text: widget.itemPrice.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الاسم لا يمكن أن يكون فارغًا')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    CollectionReference trucks =
        FirebaseFirestore.instance.collection('Food_Truck');

    try {
      DocumentSnapshot docSnapshot = await trucks.doc(widget.truckId).get();
      List<dynamic> itemNamesList = docSnapshot['item_names_list'];
      List<dynamic> itemPricesList = docSnapshot['item_prices_list'];
      List<dynamic> itemImagesList = docSnapshot['item_images_list'];

      if (nameController.text != widget.itemName) {
        itemNamesList[widget.itemIndex] = nameController.text;
      }

      if (double.tryParse(priceController.text) != widget.itemPrice) {
        itemPricesList[widget.itemIndex] =
            double.tryParse(priceController.text) ?? widget.itemPrice;
      }

      if (_imageFile != null) {
        String imageUrl = await _uploadImage(_imageFile!);
        itemImagesList[widget.itemIndex] = imageUrl;
      }

      await trucks.doc(widget.truckId).update({
        'item_names_list': itemNamesList,
        'item_prices_list': itemPricesList,
        'item_images_list': itemImagesList,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث الصنف بنجاح!')),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error updating item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث الصنف: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = 'items/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = storage.ref().child(fileName);

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Widget _buildImageDisplay() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: _imageFile != null
              ? FileImage(_imageFile!)
              : (widget.itemImage.isNotEmpty
                  ? NetworkImage(widget.itemImage)
                  : const AssetImage('assets/images/placeholder-image.jpg')
                      as ImageProvider),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kBannerColor,
        appBar: AppBar(
          backgroundColor: kBannerColor,
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
                  child: Column(
                    children: [
                      const Text(
                        'تعديل صنف',
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم العنصر';  
                            }
                            return null;
                          },
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            label: const Text(
                              'اسم العنصر',  
                              textAlign: TextAlign.center,
                            ),
                            hintText: 'ادخل اسم العنصر',  
                            hintStyle: const TextStyle(
                                color: Colors.black26),  
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
                      const SizedBox(height: 20.0),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: 'السعر',
                            hintText: 'ادخل السعر',
                            border: OutlineInputBorder(),
                          ),
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          _buildImageDisplay(),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 8.0),
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
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
                                Text(
                                  'اختر صورة جديدة',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Color.fromARGB(196, 0, 0, 0),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  size: 21,
                                  Icons.add_a_photo,
                                  color: Color.fromARGB(196, 0, 0, 0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBannerColor,
                          ),
                          onPressed: _isLoading ? null : _updateItem,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'تحديث الصنف',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
