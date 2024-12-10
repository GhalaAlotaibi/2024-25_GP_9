import 'package:flutter/material.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:tracki/Utils/constants.dart';
import 'login_screen.dart';
import 'Create_Truck_1.dart';
import '../user_auth/firebase_auth_services.dart';

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
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
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
              Navigator.pop(context); // This will return to the previous page
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
                  key: _formSignupKey,
                  child: Column(
                    children: [
                      const Text(
                        "إنشاء حساب جديد",
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Progress bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kBannerColor,
                            ),
                          ),
                          const SizedBox(width: 30),
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

                      // Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: TextFormField(
                                controller: _lastNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال الاسم الاخير';
                                  }
                                  return null;
                                },
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  labelText: 'الاسم الاخير',
                                  hintText: 'ادخل الاسم الاخير',
                                  hintStyle:
                                      const TextStyle(color: Colors.black26),
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
                                  hintStyle:
                                      const TextStyle(color: Colors.black26),
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
                            } else if (!RegExp(r'^05[0-9]{8,13}$')
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

                      //I agree to the processing
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
                            activeColor: kBannerColor,
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
                          // Disable button if loading
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kBannerColor),

                          onPressed: () async {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('جاري معالجة البيانات'),
                                ),
                              );

                              // Sign up using Firebase auth
                              String? result =
                                  await _authService.signUpWithEmailAndPassword(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                '${_firstNameController.text} ${_lastNameController.text}',
                              );

                              if (result != null &&
                                  result.length != 0 &&
                                  !isErrorMessage(result)) {
                                // Save owner data to Firestore
                                String userID = result;
                                await _authService
                                    .saveUserData(userID, 'Truck_Owner', {
                                  'Name':
                                      '${_firstNameController.text} ${_lastNameController.text}',
                                  'PhoneNum': _phoneController.text,
                                  'Email': _emailController.text,
                                });

                                // Navigate to CreateTruck1
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CreateTruck1(ownerId: userID),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text(result ?? 'فشل انشاء الحساب')),
                                );
                              }
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'يرجى الموافقة على معالجة البيانات الشخصية'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'انشاء حساب جديد',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('هل لديك حساب بالفعل؟ ',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                )),
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
                                  color: kprimaryColor,
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

  bool isErrorMessage(String message) {
    const List<String> errorMessages = [
      'يرجى إدخال بريد إلكتروني صالح',
      'البريد الإلكتروني مستخدم بالفعل',
      'تسجيل الدخول غير مفعل',
      'يجب ان تحتوي كلمة المرور 8 احرف على الاقل',
      'حدث خطأ: ',
      'كلمة المرور خاطئة',
      'المستخدم غير موجود',
      'كلمة المرور يجب أن لا تقل عن 8 خانات',
      'تسجيل الدخول غير مفعل',
      'المستخدم غير موجود'
          'كلمة المرور خاطئة',
    ];

    return errorMessages.contains(message);
  }
}
