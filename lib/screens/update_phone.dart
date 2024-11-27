import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/my_icon_button.dart';

class UpdatePhone extends StatefulWidget {
  final String ID;

  const UpdatePhone({super.key, required this.ID});

  @override
  _UpdatePhoneState createState() => _UpdatePhoneState();
}

class _UpdatePhoneState extends State<UpdatePhone> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _phoneController = TextEditingController();
  TextEditingController? _currentPhoneController;
  String? currentPhoneNumber;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
  }

  Future<void> _fetchPhoneNumber() async {
    try {
      DocumentSnapshot ownerDoc =
          await _firestore.collection('Truck_Owner').doc(widget.ID).get();

      if (ownerDoc.exists) {
        setState(() {
          currentPhoneNumber = ownerDoc['PhoneNum'];
          _currentPhoneController =
              TextEditingController(text: currentPhoneNumber);
          isLoading = false;
        });
      } else {
        _showError('لم يتم العثور على بيانات المالك');
      }
    } catch (e) {
      print('Error fetching phone number: $e');
      _showError('خطأ أثناء جلب البيانات');
    }
  }

  Future<void> _updatePhoneNumber(String newPhone) async {
    // First, validate the phone number format
    if (_validatePhoneNumber(newPhone) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_validatePhoneNumber(newPhone)!)),
      );
      return;
    }

    try {
      // Check if the new phone number already exists in Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('Truck_Owner')
          .where('PhoneNum', isEqualTo: newPhone)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رقم الجوال هذا مستخدم بالفعل'),
          ),
        );
        return; // Stop further processing if phone number is not unique
      }

      // Proceed to update the phone number in Firestore
      await _firestore
          .collection('Truck_Owner')
          .doc(widget.ID)
          .update({'PhoneNum': newPhone});

      setState(() {
        currentPhoneNumber = newPhone;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم تحديث رقم الجوال بنجاح!'),
      ));
      Navigator.pop(context, true);
    } catch (e) {
      print('Error updating phone number: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('حدث خطأ أثناء تحديث رقم الجوال: $e'),
      ));
    }
  }

  void _showError(String errorMessage) {
    setState(() {
      currentPhoneNumber = errorMessage;
      isLoading = false;
    });
  }

  String? _validatePhoneNumber(String? value) {
    // Check if the value is not empty and follows the correct format
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الجوال.';
    }
    // Validate phone number format (starts with 05 and contains exactly 10 digits)
    if (!RegExp(r'^05[0-9]{8}$').hasMatch(value)) {
      return 'الرجاء إدخال رقم هاتف صحيح';
    }
    return null; // No validation errors
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
            const SizedBox(width: 103),
            const Text(
              "تحديث رقم الجوال",
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    // Current Phone Number (read-only)
                    _currentPhoneController == null
                        ? const Center(child: CircularProgressIndicator())
                        : _buildCustomTextField(
                            controller: _currentPhoneController!,
                            labelText: 'رقم الجوال الحالي',
                            hintText: 'أدخل رقم الجوال الحالي',
                            icon: Icons.phone,
                            enabled: false,
                          ),
                    const SizedBox(height: 20),

                    // New Phone Number TextField
                    _buildCustomTextField(
                      controller: _phoneController,
                      labelText: 'رقم الجوال الجديد',
                      hintText: 'أدخل رقم الجوال الجديد',
                      icon: Icons.phone,
                      validator: _validatePhoneNumber,
                    ),

                    const SizedBox(height: 20),
                    // Save Button
                    ElevatedButton(
                      onPressed: () {
                        if (_phoneController.text.trim().isNotEmpty) {
                          _updatePhoneNumber(_phoneController.text.trim());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يرجى إدخال رقم الجوال الجديد.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBannerColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text(
                        'حفظ التغييرات',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

Widget _buildCustomTextField({
  required TextEditingController controller,
  required String labelText,
  required String hintText,
  required IconData icon,
  bool isPassword = false,
  bool enabled = true,
  String? Function(String?)? validator,
  Widget? suffixIcon,
}) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: TextFormField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF6F6F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      validator: validator,
    ),
  );
}
