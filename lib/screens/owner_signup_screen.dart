import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:tracki/Utils/constants.dart';
import 'login_screen.dart';
import 'Create_Truck_1.dart';

class OwnerSignUpScreen extends StatefulWidget {
  const OwnerSignUpScreen({super.key});

  @override
  State<OwnerSignUpScreen> createState() => _OwnerSignUpScreenState();
}

class _OwnerSignUpScreenState extends State<OwnerSignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

  // Controllers for the form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBannerColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF674188),
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
                  key: _formSignupKey,
                  child: Column(
                    children: [
                      const Text(
                        "إنشاء حساب جديد",
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF674188),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),

                      // Name
                      Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjust alignment if needed
  children: [
    Expanded(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          controller: _lastNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال الاسم الثاني';
            }
            return null;
          },
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: 'الاسم الثاني',
            hintText: 'ادخل الاسم الثاني',
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
        ),
      ),
    ),
    SizedBox(width: 10), // Add spacing between the fields
    Expanded(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          controller: _firstNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال الاسم الأول';
            }
            return null;
          },
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: 'الاسم الأول',
            hintText: 'ادخل الاسم الأول',
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
        ),
      ),
    ),
  ],
),


                      const SizedBox(height: 25.0),

                      // Phone number
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            } else if (!RegExp(r'^[0-9]{10,15}$')
                                .hasMatch(value)) {
                              return 'الرجاء إدخال رقم هاتف صحيح';
                            }
                            return null;
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'رقم الهاتف',
                            hintText: 'ادخل رقم الهاتف',
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
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Email
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال البريد الإلكتروني';
                            }
                            return null;
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            hintText: 'ادخل البريد الإلكتروني',
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
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Password
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          obscuringCharacter: '*',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال الرمز السري';
                            }
                            return null;
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'الرمز السري',
                            hintText: 'ادخل الرمز السري',
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
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // I agree to the processing
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor:
                                const Color.fromARGB(255, 105, 99, 197),
                          ),
                          const Text(
                            'أوافق على السماح بمعالجة البيانات الشخصية',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // Sign up button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('جاري معالجة البيانات'),
                                ),
                              );

                              // Add owner to the Firestore database
                              addOwnerToDatabase().then((ownerId) {
                                if (ownerId != null) {
                                  // Navigate to CreateTruck1 after successful registration
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      //passes the owner's autogenerated id
                                      builder: (context) =>
                                          CreateTruck1(ownerId: ownerId),
                                    ),
                                  );
                                }
                              });
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'يرجى الموافقة على معالجة البيانات الشخصية'),
                                ),
                              );
                            }
                          },
                          child: const Text('انشاء حساب جديد'),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'هل لديك حساب بالفعل؟ ',
                              style: TextStyle(color: Colors.black45),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) => const LogInScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 139, 65, 174),
                                ),
                              ),
                            ),
                          ],
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

  //DB
Future<String?> addOwnerToDatabase() async {
  CollectionReference owners =
      FirebaseFirestore.instance.collection('Truck_Owner');

  // Check if the email already exists
  QuerySnapshot emailQuerySnapshot =
      await owners.where('Email', isEqualTo: _emailController.text).get();

  if (emailQuerySnapshot.docs.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('البريد الإلكتروني مسجل مسبقًا!'),
      ),
    );
    return null; // Indicate failure
  }

  // Check if the phone number already exists
  QuerySnapshot phoneQuerySnapshot =
      await owners.where('PhoneNum', isEqualTo: _phoneController.text).get();

  if (phoneQuerySnapshot.docs.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('رقم الهاتف مسجل مسبقًا!'),
      ),
    );
    return null; // Indicate failure
  }

  try {
    // Combine first and last name
    String fullName = '${_firstNameController.text} ${_lastNameController.text}';
    
    DocumentReference docRef = await owners.add({
      'Name': fullName, // Use combined name
      'PhoneNum': _phoneController.text,
      'Email': _emailController.text,
      // Hash the password securely (not shown for simplicity)
    });

    return docRef.id; // Return the Owner ID for navigation
  } catch (e) {
    print('Error adding owner: $e');
    return null;
  }
}

}
