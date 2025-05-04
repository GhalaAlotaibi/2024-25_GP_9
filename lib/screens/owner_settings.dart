import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/login_screen.dart';
import 'package:tracki/screens/update_email.dart';
import 'package:tracki/screens/update_password.dart';
import 'package:tracki/screens/update_phone.dart';

import '../user_auth/firebase_auth_services.dart';

class OwnerSettings extends StatefulWidget {
  final String ownerID;

  const OwnerSettings({super.key, required this.ownerID});

  @override
  _OwnerSettingsState createState() => _OwnerSettingsState();
}
//تحديث

class _OwnerSettingsState extends State<OwnerSettings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  String? ownerName;
  String? truckOwnerID; // Store the ownerID for reuse
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOwnerData();
  }

  Future<void> _fetchOwnerData() async {
    try {
      // Fetch the truck document using its ID
      DocumentSnapshot truckDoc =
          await _firestore.collection('Food_Truck').doc(widget.ownerID).get();

      if (truckDoc.exists) {
        // Retrieve the ownerID from the truck document
        truckOwnerID = truckDoc['ownerID'];

        if (truckOwnerID != null) {
          // Fetch the owner document from the Truck_Owner collection
          DocumentSnapshot ownerDoc = await _firestore
              .collection('Truck_Owner')
              .doc(truckOwnerID)
              .get();

          if (ownerDoc.exists) {
            setState(() {
              ownerName = ownerDoc['Name'];
              isLoading = false;
            });
          } else {
            _setError('لم يتم العثور على المالك');
          }
        } else {
          _setError('لم يتم العثور على رقم المالك');
        }
      } else {
        _setError('لم يتم العثور على الشاحنة');
      }
    } catch (e) {
      print('Error fetching owner data: $e');
      _setError('خطأ في جلب البيانات');
    }
  }

  void _setError(String errorMessage) {
    setState(() {
      ownerName = errorMessage;
      isLoading = false;
    });
  }

  Future<void> _updateOwnerName(String newName) async {
    if (truckOwnerID == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('لم يتم العثور على رقم المالك.'),
      ));
      return;
    }

    try {
      // Update the Name field in the Truck_Owner document
      await _firestore
          .collection('Truck_Owner')
          .doc(truckOwnerID)
          .update({'Name': newName});

      setState(() {
        ownerName = newName;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم تحديث الاسم بنجاح!'),
      ));
    } catch (e) {
      print('Error updating name: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('حدث خطأ أثناء تحديث الاسم: $e'),
      ));
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    bool shouldLogOut = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: kbackgroundColor,
              title: const Text(
                'تأكيد تسجيل الخروج',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                textDirection: TextDirection.rtl,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User cancels logout
                  },
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: const Text('إلغاء'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirms logout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBannerColor,
                  ),
                  child: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is closed without a response

    // Proceed with sign-out if the user confirmed the logout
    if (shouldLogOut) {
      try {
        await _authService.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogInScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  void _showDeleteAccountConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kbackgroundColor,
          title: const Text(
            'تأكيد حذف الحساب',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.pop(context);

                  //ADD TO HISTORY
                  // Retrieve the owner details before deletion (owner name, ownerID)
                  DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
                      .collection('Truck_Owner')
                      .doc(truckOwnerID)
                      .get();

                  if (ownerDoc.exists) {
                    String ownerName = ownerDoc.get('Name');
                    String ownerID = ownerDoc.id;

                    // Save the deletion history to the History collection
                    await FirebaseFirestore.instance.collection('History').add({
                      'docType': 'Owner Deletion',
                      'details': 'حذف حساب $ownerName برقم المعرف $ownerID',
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    // Delete account from Firestore
                    await FirebaseFirestore.instance
                        .collection('Truck_Owner')
                        .doc(truckOwnerID)
                        .delete();

                    // Navigate to login screen after deletion
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('لم يتم العثور على بيانات صاحب العربة.'),
                    ));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('حدث خطأ أثناء حذف الحساب: $e'),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 152, 25, 25),
              ),
              child: const Text(
                'حذف',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateNameDialog() {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kbackgroundColor,
          title: const Text(
            'تحديث الاسم',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الجديد',
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBannerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBannerColor),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  _updateOwnerName(nameController.text.trim());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBannerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'حفظ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Center(
          child: Text(
            "الإعدادات",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Text(
                            'أهلًا ${ownerName ?? ''}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Iconsax.edit,
                              size: 20,
                            ),
                            onPressed: _showUpdateNameDialog,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (truckOwnerID != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateEmail(
                                ID: truckOwnerID!,
                                userType: "owner",
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('رقم المالك غير متوفر حالياً.')),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Icon(Icons.email,
                                  color: Color.fromARGB(200, 72, 72, 72)),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'تحديث البريد الإلكتروني',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(right: 20.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                                size: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdatePassword(
                              ID: widget.ownerID,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Icon(Icons.lock,
                                  color: Color.fromARGB(200, 72, 72, 72)),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'تحديث الرمز السري',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(right: 20.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                                size: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (truckOwnerID != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdatePhone(
                                ID: truckOwnerID!,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('رقم المالك غير متوفر حالياً.')),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Icon(Icons.email,
                                  color: Color.fromARGB(200, 72, 72, 72)),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'تحديث رقم الهاتف',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(right: 20.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                                size: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 220),

                    // Logout Button
                    ElevatedButton(
                      onPressed: _showLogoutConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBannerColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Delete Account Button
                    GestureDetector(
                      onTap: _showDeleteAccountConfirmationDialog,
                      child: Text(
                        'حذف الحساب',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 152, 25, 25),
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
