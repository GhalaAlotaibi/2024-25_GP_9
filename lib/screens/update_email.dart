import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/my_icon_button.dart';

class UpdateEmail extends StatefulWidget {
  final String ID;
  final String userType; // "owner" or "customer"

  const UpdateEmail({Key? key, required this.ID, required this.userType})
      : super(key: key);

  @override
  _UpdateEmailState createState() => _UpdateEmailState();
}

class _UpdateEmailState extends State<UpdateEmail> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController currentEmailController = TextEditingController();
  TextEditingController newEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = true;
  bool isPasswordVisible = false;

  Future<void> _fetchUserData() async {
    try {
      String collection =
          widget.userType == "owner" ? "Truck_Owner" : "Customer";
      String syntax = widget.userType == "owner" ? "Email" : "email";
      DocumentSnapshot document =
          await _firestore.collection(collection).doc(widget.ID).get();

      if (document.exists) {
        setState(() {
          currentEmailController.text = document[syntax] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        String collection =
            widget.userType == "owner" ? "Truck_Owner" : "Customer";
        String syntax = widget.userType == "owner" ? "Email" : "email";

        // Check if email already exists in Firestore
        final emailExists = await _firestore
            .collection(collection)
            .where(syntax, isEqualTo: newEmailController.text)
            .get();

        if (emailExists.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هذا البريد مستخدم بالفعل')),
          );
          return;
        }

        User? user = _auth.currentUser;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم العثور على المستخدم')),
          );
          return;
        }

        AuthCredential credential = EmailAuthProvider.credential(
          email: currentEmailController.text,
          password: passwordController.text,
        );

        try {
          await user.reauthenticateWithCredential(credential);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('كلمة المرور غير صحيحة')),
          );
          return;
        }

        await user.updateEmail(newEmailController.text);

        await user.sendEmailVerification();

        await _firestore
            .collection(collection)
            .doc(widget.ID)
            .update({syntax: newEmailController.text});

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("تم تحديث البريد الإلكتروني بنجاح"),
        ));

        Navigator.pop(context, true);
      } catch (e) {
        print('Error updating email: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('حدث خطأ أثناء تحديث البريد الإلكتروني: $e'),
        ));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true, // Ensures center alignment
        title: const Text(
          "تحديث البريد الإلكتروني",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildCustomTextField(
                        controller: currentEmailController,
                        labelText: 'البريد الإلكتروني الحالي',
                        hintText: 'أدخل البريد الإلكتروني الحالي',
                        icon: Icons.email,
                        enabled: false,
                      ),
                      const SizedBox(height: 20),
                      _buildCustomTextField(
                        controller: newEmailController,
                        labelText: 'البريد الإلكتروني الجديد',
                        hintText: 'أدخل البريد الإلكتروني الجديد',
                        icon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء ادخال البريد الجديد';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'البريد غير صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildCustomTextField(
                        controller: passwordController,
                        labelText: 'كلمة المرور', //كلمة المرور
                        hintText: '********',
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء ادخال كلمة المرور';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _updateEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBannerColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'حفظ التغييرات',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}
