import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/food_truck_profile_display.dart';
import 'package:tracki/screens/login_screen.dart';
import 'package:tracki/screens/view_all_items.dart';
import 'package:tracki/widgets/banner.dart';
import 'package:tracki/widgets/items_display.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import '../user_auth/firebase_auth_services.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MyAppHomeScreen extends StatefulWidget {
  final String customerID;
  const MyAppHomeScreen({super.key, required this.customerID});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

//setState
class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "الكل";
  String selectedCategoryId = "";
  late final String cID = widget.customerID;
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool isLoadingRecommendations = false; // Track loading state
  void initState() {
    super.initState();
    // we must call getRecommendations whenever the page is loaded
    getRecommendations();
  }

  List<DocumentSnapshot> recommendedTrucks = [];
  void getRecommendations() async {
    setState(() {
      isLoadingRecommendations = true; // Start loading
    });

    String userId = widget.customerID;
    Position? currentPosition = await _getCurrentLocation();

    if (currentPosition == null) {
      print("Failed to fetch current location.");
      setState(() {
        isLoadingRecommendations = false; // Stop loading
      });
      return;
    }

    double lat = currentPosition.latitude;
    double lon = currentPosition.longitude;

    List<String> recommendedTruckIDs =
        await fetchRecommendedFoodTrucks(userId, lat, lon);

    if (recommendedTruckIDs.isNotEmpty) {
      List<DocumentSnapshot> fetchedTrucks =
          await fetchTruckDetails(recommendedTruckIDs);
      if (mounted) {
        setState(() {
          recommendedTrucks = fetchedTrucks;
        });
      }
    }

    if (mounted) {
      setState(() {
        isLoadingRecommendations = false; // Stop loading
      });
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permissions are denied.");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied.");
        return null;
      }

      // Fetch the current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Error fetching location: $e");
      return null;
    }
  }

  Future<List<DocumentSnapshot>> fetchTruckDetails(
      List<String> truckIDs) async {
    List<DocumentSnapshot> truckList = [];
    for (String id in truckIDs) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Food_Truck")
          .doc(id)
          .get();
      if (doc.exists) {
        truckList.add(doc);
      }
    }
    return truckList;
  }

  final CollectionReference categoriesItems =
      FirebaseFirestore.instance.collection("Food-Category");

  Query get allItems => FirebaseFirestore.instance.collection("Food_Truck");
  Query get selectedTrucks => category == "الكل" ? allItems : filteredItems;

  Query get filteredItems => FirebaseFirestore.instance
      .collection("Food_Truck")
      .where("categoryId", isEqualTo: selectedCategoryId);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: kbackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      headerParts(),
                      const SizedBox(height: 20),
                      //  mySearchBar(),
                      const BannerToExplore(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "التصنيفات",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: selectedCategory(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ViewAllItems(customerID: cID)),
                              );
                            },
                            child: const Text(
                              "عرض الكل",
                              style: TextStyle(
                                color: kBannerColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Text(
                            "عربات الطعام",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: selectedTrucks
                            .snapshots(), // This will update based on the selected category
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return const Center(
                                child: Text("Error loading data"));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text("لا توجد عربات طعام."));
                          }

                          final trucks = snapshot.data!.docs;

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5, left: 0),
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: trucks
                                          .map((e) => ItemsDisplay(
                                                documentSnapshot: e,
                                                customerID: widget.customerID,
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Text(
                                    "مقترحات لك",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Show loading spinner while fetching recommendations
                              if (isLoadingRecommendations)
                                const Center(child: CircularProgressIndicator())
                              else if (recommendedTrucks.isEmpty)
                                const Center(
                                    child: Text("لا توجد عربات مقترحة متاحة."))
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: suggestedTrucksRow(
                                      recommendedTrucks, widget.customerID),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> selectedCategory() {
    return StreamBuilder(
      stream: categoriesItems.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                streamSnapshot.data!.docs.length,
                (index) {
                  final categoryDoc = streamSnapshot.data!.docs[index];
                  final categoryName = categoryDoc["name"];
                  final categoryId = categoryDoc.id;

                  return GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          selectedCategoryId = categoryId;
                          category = categoryName;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: selectedCategoryId == categoryId
                            ? kprimaryColor
                            : Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.only(right: 1, left: 15),
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: selectedCategoryId == categoryId
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Padding mySearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            filled: true,
            prefixIcon: const Icon(Iconsax.search_normal),
            fillColor: Colors.white,
            border: InputBorder.none,
            hintText: "ابحث عن عربة طعام",
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Row headerParts() {
    return Row(
      children: [
        MyIconButton(
            icon: Iconsax.logout_14,
            pressed: () async {
              final shouldLogOut = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        backgroundColor:
                            kbackgroundColor, // Set background color
                        title: const Text(
                          'تأكيد تسجيل الخروج',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                          textDirection: TextDirection.rtl,
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: const Text('إلغاء'),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
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
                  false;

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
            }),
        const Spacer(),
        const Text(
          "ما هي عربة \nالطعام التي تبحث عنها؟",
          style:
              TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

Widget suggestedTrucksRow(List<DocumentSnapshot> trucks, String customerID) {
  return FutureBuilder<List<DocumentSnapshot>>(
    future: _getAcceptedTrucks(trucks),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return const Center(child: Text("Error loading data"));
      }

      final acceptedTrucks = snapshot.data ?? [];

      if (acceptedTrucks.isEmpty) {
        return const Center(child: Text("لا توجد عربات مقترحة متاحة."));
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: acceptedTrucks.reversed.map((truck) {
            // Reverse list manually
            final imageUrl = truck['truckImage'] ?? ''; // Avoid null errors
            final truckName = truck['name'] ?? 'غير معروف'; // Default name

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodTruckProfileDisplay(
                      documentSnapshot: truck, // Pass the specific truck's data
                      customerID: customerID,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  children: [
                    // Truck Image Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 140,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // Placeholder background
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(2, 4),
                            )
                          ],
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported,
                                        size: 60),
                              )
                            : const Icon(Icons.image_not_supported, size: 60),
                      ),
                    ),

                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Truck Name Overlay
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Text(
                        truckName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    },
  );
}

Future<List<DocumentSnapshot>> _getAcceptedTrucks(
    List<DocumentSnapshot> trucks) async {
  final CollectionReference requestCollection =
      FirebaseFirestore.instance.collection("Request");

  List<DocumentSnapshot> acceptedTrucks = [];

  for (var truck in trucks) {
    final String statusId = truck['statusId'];
    try {
      final requestDoc = await requestCollection.doc(statusId).get();
      if (requestDoc.exists && requestDoc['status'] == 'accepted') {
        acceptedTrucks.add(truck);
      }
    } catch (e) {
      print('Error checking truck status for $statusId: $e');
    }
  }
  return acceptedTrucks;
}

Future<List<String>> fetchRecommendedFoodTrucks(
    String userId, double lat, double lon) async {
  final Uri url = Uri.parse(
      'http://10.0.2.2:5000/recommend?user_id=$userId&lat=$lat&lon=$lon');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data["recommended_food_trucks"]);
    } else {
      throw Exception("Failed to load recommendations");
    }
  } catch (e) {
    print("Error fetching recommendations: $e");
    return [];
  }
}
//24.7082, 46.5989
