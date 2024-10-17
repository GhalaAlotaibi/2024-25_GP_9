import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF674188),
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
                    // Set text direction to RTL
                    children: [
                      // Get started text
                      const Text(
                        'Ownerإنشاء حساب جديد',
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF674188),
                        ),
                        textAlign: TextAlign.center, // Align text to the right
                      ),
                      const SizedBox(height: 20.0), // Adjusted space

// Full name
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم المستخدم';
                          }
                          return null;
                        },
                        textAlign: TextAlign.right, // Align text to the right
                        decoration: InputDecoration(
                          label: const Text('اسم المستخدم',
                              textAlign:
                                  TextAlign.center), // Right-aligned label
                          hintText: 'ادخل اسم المستخدم',
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
                      const SizedBox(height: 25.0),

 // Phone number 
 TextFormField(
  keyboardType: TextInputType.phone, // Set keyboard type to phone
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    } else if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
      return 'الرجاء إدخال رقم هاتف صحيح';
    }
    return null;
  },
  textAlign: TextAlign.right, // Align text to the right
  decoration: InputDecoration(
    label: const Text('رقم الهاتف', 
        textAlign: TextAlign.center), // Right-aligned label
    hintText: 'ادخل رقم الهاتف',
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
const SizedBox(height: 25.0),

// Email
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال البريد الإلكتروني';
                          }
                          return null;
                        },
                        textAlign: TextAlign.right, // Align text to the right
                        decoration: InputDecoration(
                          labelText:
                              'البريد الإلكتروني', // Use labelText instead of label
                          hintText: 'ادخل البريد الإلكتروني',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                              10, 15, 10, 15), // Adjust padding
                        ),
                      ),
                      const SizedBox(height: 25.0), 

// Password
                      TextFormField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الرمز السري';
                          }
                          return null;
                        },
                        textAlign: TextAlign.right, // Align text to the right
                        decoration: InputDecoration(
                          labelText:
                              'الرمز السري', // Use labelText instead of label
                          hintText: 'ادخل الرمز السري',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                              10, 15, 10, 15), // Adjust padding
                        ),
                      ),
                      const SizedBox(height: 25.0),

// I agree to the processing
                      Row(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
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
                            'أوافق على  السماح بمعالجة البيانات الشخصية',
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
      if (_formSignupKey.currentState!.validate() && agreePersonalData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('جاري معالجة البيانات'),
          ),
        );

        // Navigate to CreateFoodTruckPage after successful validation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateTruck1(), // Redirect to CreateFoodTruck Page1
          ),
        );
      } else if (!agreePersonalData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى الموافقة على معالجة البيانات الشخصية'),
          ),
        );
      }
    },
    child: const Text('انشاء حساب جديد'),
  ),
),

                      const SizedBox(height: 30.0),
//
                      Directionality(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'هل لديك حساب بالفعل؟ ',
                              style: TextStyle(color: Colors.black45),
                            ),
                            const SizedBox(
                                width: 5), // Add some space between the texts
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