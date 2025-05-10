import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/chatbot.dart';
import 'package:tracki/screens/menu_update.dart';
import 'package:tracki/screens/owner_profile.dart';
import 'package:tracki/screens/owner_reviews.dart';
import 'package:tracki/widgets/banner2.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'package:tracki/screens/login_screen.dart';
import '../user_auth/firebase_auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerHomeScreen extends StatefulWidget {
  final String ownerID; //the doc id not the ownerID !!
  const OwnerHomeScreen({Key? key, required this.ownerID}) : super(key: key);
  @override
  _OwnerHomeScreenState createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  String? suspensionMessage; // Store the suspension message
  @override
  @override
  void initState() {
    super.initState();
    // Listen to changes in the Food_Truck collection
    getFoodTruckStream().listen((foodTruckSnapshot) {
      if (foodTruckSnapshot.exists) {
        print("Food Truck Data Updated: ${foodTruckSnapshot.data()}");
      }
    });
    // Listen to changes in the Request collection
    getRequestStream().listen((requestSnapshot) {
      if (requestSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> requestData =
            requestSnapshot.docs.first.data() as Map<String, dynamic>;
        print("Request Data Updated: $requestData");
        // Check the suspension status
        if (requestData['status'] == 'suspended') {
          setState(() {
            suspensionMessage =
                'تم تعليق حسابك. لمزيد من المعلومات، يرجى التواصل مع المسؤول عبر البريد الإلكتروني tracki1ad@gmail.com.';
          });
        } else {
          setState(() {
            suspensionMessage = null; // Clear the message if not suspended
          });
        }
      }
    });
  }

  Future<Map<String, dynamic>> fetchOwnerData(String ownerID) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Food_Truck')
        .doc(ownerID)
        .get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('Truck not found');
    }
  }

  Stream<DocumentSnapshot> getFoodTruckStream() {
    return FirebaseFirestore.instance
        .collection('Food_Truck')
        .doc(widget.ownerID)
        .snapshots();
  }

  Stream<QuerySnapshot> getRequestStream() {
    return FirebaseFirestore.instance
        .collection('Request')
        .where('foodTruckId', isEqualTo: widget.ownerID)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchOwnerData(widget.ownerID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var ownerData = snapshot.data!;
          String truckImageUrl = ownerData['truckImage'] ?? '';
          String businessLogo = ownerData['businessLogo'] ?? '';
          String operatingHours =
              ownerData['operatingHours'] ?? 'Not available';
          String rating = ownerData['rating']?.toString() ?? 'N/A';
          int ratingCount = ownerData['ratingsCount'] ?? 0;
          String ownerID = ownerData['ownerID'] ?? 'Unknown';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                buildWelcomeMessage(businessLogo, ownerID),
                const SizedBox(height: 20),
                const Banner2(),
                const SizedBox(height: 20),
                buildServiceSection(context, ratingCount),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildWelcomeMessage(String logoUrl, String ownerID) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 19, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: MyIconButton(
              icon: Iconsax.logout_14,
              pressed: () async {
                // Show confirmation dialog before signing out
                final shouldLogOut = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          backgroundColor: kbackgroundColor,
                          title: const Text(
                            'تأكيد تسجيل الخروج',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                            textDirection: TextDirection.rtl,
                          ),
                          actions: <Widget>[
                            // Cancel Button
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext)
                                    .pop(false); // Cancel action
                              },
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: const Text('إلغاء'),
                              ),
                            ),
                            // Confirm Logout Button with banner color
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext)
                                    .pop(true); // Confirm Logout action
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    kBannerColor, // Set button color to banner color
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
                      MaterialPageRoute(
                          builder: (context) => const LogInScreen()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $e')),
                    );
                  }
                }
                // If confirmed, proceed with sign-out
                if (shouldLogOut == true) {
                  try {
                    await _authService.signOut(); // Sign out from Firebase
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) =>
                            const LogInScreen(), // Navigate to login page
                      ),
                      (Route<dynamic> route) =>
                          route.settings.name == '/welcome_screen',
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $e')),
                    );
                  }
                }
              },
            ),
          ),
          Row(
            children: [
              Text(
                'أهلًا بك',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(width: 10),
              buildBusinessLogo(logoUrl),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBusinessLogo(String logoUrl) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(logoUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildSuspensionMessage(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildServiceSection(BuildContext context, int ratingCount) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildServiceCardWithAnimation(
              title: '---------',
              color: const Color.fromARGB(255, 255, 255, 255),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatbotUI(),
                  ),
                );
              },
            ),
            buildServiceCard(
              icon: Iconsax.truck,
              title: 'بيانات العربة',
              color: kprimaryColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OwnerProfile(ownerID: widget.ownerID),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildServiceCard(
              icon: Iconsax.like_tag,
              title: "التقييمات",
              color: kBannerColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OwnerReviews(ownerID: widget.ownerID),
                  ),
                );
              },
            ),
            buildServiceCard(
              icon: Iconsax.menu,
              title: 'قائمة الطعام ',
              color: kBannerColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuUpdate(ownerID: widget.ownerID),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Add the suspension message below the squares
        if (suspensionMessage != null)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20), // Adjust spacing
            child: buildSuspensionMessage(suspensionMessage!),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildServiceCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(255, 255, 255, 255),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
        child: Container(
          width: 170,
          height: 160,
          padding: const EdgeInsets.all(3.4),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30, right: 30),
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
              Align(
                //
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: Icon(
                      icon,
                      size: 30,
                      color: const Color.fromARGB(136, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildServiceCardWithAnimation({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: kprimaryColor,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Container(
          width: 177,
          height: 160,
          padding: const EdgeInsets.all(3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                height: 110,
                child: Lottie.network(
                  'https://lottie.host/5d637a4b-34c1-4a41-bc86-b7371253a938/tTgShfWw5l.json',
                  fit: BoxFit.fill,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
