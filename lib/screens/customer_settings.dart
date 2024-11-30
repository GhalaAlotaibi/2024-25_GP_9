import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/favourites_page.dart';
import 'package:tracki/screens/login_screen.dart';
import 'package:tracki/screens/update_email.dart';
import 'package:tracki/screens/update_password.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import '../user_auth/firebase_auth_services.dart';

class CustomerSettings extends StatefulWidget {
  final String customerID;

  const CustomerSettings({Key? key, required this.customerID})
      : super(key: key);

  @override
  _CustomerSettingsState createState() => _CustomerSettingsState();
}

class _CustomerSettingsState extends State<CustomerSettings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  String? customerName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomerName();
  }

  Future<void> _fetchCustomerName() async {
    try {
      DocumentSnapshot document =
          await _firestore.collection('Customer').doc(widget.customerID).get();
      if (mounted) {
        if (document.exists) {
          setState(() {
            customerName = document['Name'];
            isLoading = false;
          });
        } else {
          setState(() {
            customerName = 'مستخدم غير معروف';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching customer name: $e');
      setState(() {
        customerName = 'خطأ في جلب البيانات';
        isLoading = false;
      });
    }
  }

  Future<void> _updateCustomerName(String newName) async {
    try {
      await _firestore
          .collection('Customer')
          .doc(widget.customerID)
          .update({'Name': newName});
      setState(() {
        customerName = newName;
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
          content: Directionality(
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
                  _updateCustomerName(nameController.text.trim());
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

  void _showDeleteAccountConfirmationDialog() async {
    final shouldDelete = await showDialog<bool>(
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
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
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

    if (shouldDelete == true) {
      try {
        // Delete account from Firestore
        await _firestore.collection('Customer').doc(widget.customerID).delete();
        // Navigate to login screen after deletion
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حذف الحساب: $e'),
          ),
        );
      }
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
            const SizedBox(width: 113),
            const Text(
              "       الإعدادات",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
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
                            'أهلًا ${customerName ?? ''}',
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

                    // First clickable rectangle (email update)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateEmail(
                              ID: widget.customerID,
                              userType: "Customer",
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
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Icon(Icons.email,
                                  color: Color.fromARGB(200, 72, 72, 72)),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'تحديث الإيميل',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            const Padding(
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

                    // Second clickable rectangle (password update)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdatePassword(
                              ID: widget.customerID,
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
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Icon(Icons.lock,
                                  color: Color.fromARGB(200, 72, 72, 72)),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'تحديث كلمة المرور',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            const Padding(
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
                            builder: (context) => const FavoritesPage(),
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
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Icon(Iconsax.heart5, color: kprimaryColor),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "مفضلاتي",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            const Padding(
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
                          decoration: TextDecoration
                              .underline, // Optional for clickable text
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
