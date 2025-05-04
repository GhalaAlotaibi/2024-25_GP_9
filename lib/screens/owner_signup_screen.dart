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
  String? phoneErrorText;
  String? emailErrorText;
  String? passwordErrorText;

  String? firstNameErrorText;
  String? lastNameErrorText;

// Add this function inside the _OwnerSignUpScreenState class
  bool validateAllFields() {
    setState(() {
      // Trigger validation for all fields

      // First Name Validation
      if (_firstNameController.text.isEmpty) {
        firstNameErrorText = 'الرجاء إدخال الاسم الأول';
      } else if (!RegExp(r'^[\p{L} ]+$', unicode: true)
          .hasMatch(_firstNameController.text)) {
        firstNameErrorText = 'الرجاء إدخال أحرف فقط';
      } else {
        firstNameErrorText = null;
      }

      // Last Name Validation
      if (_lastNameController.text.isEmpty) {
        lastNameErrorText = 'الرجاء إدخال الاسم الأخير';
      } else if (!RegExp(r'^[\p{L} ]+$', unicode: true)
          .hasMatch(_lastNameController.text)) {
        lastNameErrorText = 'الرجاء إدخال أحرف فقط';
      } else {
        lastNameErrorText = null;
      }
      if (_phoneController.text.isEmpty) {
        phoneErrorText = 'الرجاء إدخال رقم الهاتف';
      } else if (!RegExp(r'^05[0-9]{8}$').hasMatch(_phoneController.text)) {
        phoneErrorText =
            'الرجاء إدخال رقم هاتف صحيح يتكون من 10 أرقام ويبدأ بـ 05';
      } else {
        phoneErrorText = null;
      }
      if (_emailController.text.isEmpty) {
        emailErrorText = 'الرجاء إدخال البريد الإلكتروني';
        print("Email is empty"); //test
      } else if (!RegExp(
              r'^[\w\.-]+@(?:gmail\.com|hotmail\.com|yahoo\.com|outlook\.com)$')
          .hasMatch(_emailController.text)) {
        print("Invalid email domain"); //test
        emailErrorText = '.الرجاء إدخال بريد إلكتروني صالح';
      } else {
        print("Email format is valid"); //test
        emailErrorText = null;
      }
      if (_passwordController.text.isEmpty) {
        passwordErrorText = 'الرجاء إدخال الرمز السري';
      } else if (_passwordController.text.length < 8) {
        passwordErrorText = 'يجب أن لا يقل الرمز السري عن 8 خانات';
      } else if (!RegExp(r'^(?=.*\d)(?=.*[a-zA-Z]).{8,}$')
          .hasMatch(_passwordController.text)) {
        passwordErrorText = 'يجب أن يحتوي الرمز السري على أحرف وأرقام';
      } else {
        passwordErrorText = null;
      }
    });
    // Return true if no errors are present
    // Return true only if all fields are valid
    return firstNameErrorText == null &&
        lastNameErrorText == null &&
        phoneErrorText == null &&
        emailErrorText == null &&
        passwordErrorText == null;
  }

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
        backgroundColor: kBannerColor,
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
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      lastNameErrorText =
                                          'الرجاء إدخال الاسم الاخير';
                                    } else if (!RegExp(r'^[\p{L} ]+$',
                                            unicode: true)
                                        .hasMatch(value)) {
                                      lastNameErrorText =
                                          'الرجاء إدخال أحرف فقط';
                                    } else {
                                      lastNameErrorText = null;
                                    }
                                  });
                                },
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  labelText: 'الاسم الاخير',
                                  hintText: 'ادخل الاسم الاخير',
                                  errorText: lastNameErrorText,
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
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      firstNameErrorText =
                                          'الرجاء إدخال الاسم الأول';
                                    } else if (!RegExp(r'^[\p{L} ]+$',
                                            unicode: true)
                                        .hasMatch(value)) {
                                      firstNameErrorText =
                                          'الرجاء إدخال أحرف فقط';
                                    } else {
                                      firstNameErrorText = null;
                                    }
                                  });
                                },
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  labelText: 'الاسم الأول',
                                  hintText: 'ادخل الاسم الأول',
                                  errorText: firstNameErrorText,
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
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                phoneErrorText = 'الرجاء إدخال رقم الهاتف';
                              } else if (!RegExp(r'^05[0-9]{8}$')
                                  .hasMatch(value)) {
                                phoneErrorText =
                                    'الرجاء إدخال رقم هاتف صحيح يتكون من 10 أرقام ويبدأ بـ 05';
                              } else {
                                phoneErrorText = null;
                              }
                            });
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'رقم الهاتف',
                            hintText: 'ادخل رقم الهاتف',
                            errorText: phoneErrorText,
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

                      /// 📧 **Email Field with Real-Time Validation**
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                emailErrorText =
                                    'الرجاء إدخال البريد الإلكتروني';
                              } else if (!RegExp(
                                      r'^[\w\.-]+@(?:gmail\.com|hotmail\.com|yahoo\.com|outlook\.com)$')
                                  .hasMatch(value)) {
                                emailErrorText =
                                    '.الرجاء إدخال بريد إلكتروني صالح';
                              } else {
                                emailErrorText = null;
                              }
                            });
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            hintText: 'ادخل البريد الإلكتروني',
                            errorText: emailErrorText,
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

                      /// 🔐 **Password Field with Real-Time Validation**
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          obscuringCharacter: '*',
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                passwordErrorText = 'الرجاء إدخال الرمز السري';
                              } else if (value.length < 8) {
                                passwordErrorText =
                                    'يجب أن لا يقل الرمز السري عن 8 خانات';
                              } else if (!RegExp(
                                      r'^(?=.*\d)(?=.*[a-zA-Z]).{8,}$')
                                  .hasMatch(value)) {
                                passwordErrorText =
                                    'يجب أن يحتوي الرمز السري على أحرف وأرقام';
                              } else {
                                passwordErrorText = null;
                              }
                            });
                          },
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'الرمز السري',
                            hintText: 'ادخل الرمز السري',
                            errorText: passwordErrorText,
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
                            print(
                                "Form Valid: ${_formSignupKey.currentState!.validate()}"); //all tests
                            print(
                                "Fields Valid: ${validateAllFields()}"); //all tests
                            print(
                                "Agreement checked: $agreePersonalData"); //all tests

                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData &&
                                validateAllFields()) {
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

                              print("Firebase result: $result"); //test

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

                                // ADD TO HISTORY
                                await FirebaseFirestore.instance
                                    .collection('History')
                                    .add({
                                  'docType': 'Truck Owner Registration',
                                  'Details':
                                      'إنشاء حساب صاحب عربة ${_firstNameController.text} ${_lastNameController.text} برقم المعرف $userID',
                                  'timestamp': FieldValue.serverTimestamp(),
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
