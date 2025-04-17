import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/customer_reviews.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'package:tracki/screens/owner_reviews.dart';
import 'package:tracki/screens/profile_map.dart';
import 'package:tracki/screens/EmbeddedMap.dart';

// Customers' side
class FoodTruckProfileDisplay extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  final customerID;
  const FoodTruckProfileDisplay(
      {super.key, required this.documentSnapshot, required this.customerID});

  @override
  State<FoodTruckProfileDisplay> createState() =>
      _FoodTruckProfileDisplayState();
}

class _FoodTruckProfileDisplayState extends State<FoodTruckProfileDisplay> {
  @override
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isFavorite = false;
  String categoryName = '';
  double averageRating = 0.0;
  int reviewsCount = 0;
  double totalRating = 0.0;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _incrementViewCounter(); // COUNTER
    _checkIfFavorite();
    _loadCategoryName();
    _fetchReviews();
  }

//COUNTER
  Future<void> _incrementViewCounter() async {
    try {
      await _firestore
          .collection('Food_Truck')
          .doc(widget.documentSnapshot.id)
          .update({
        'TruckCounter': FieldValue.increment(1), // Increment by 1
      });
      print("Counter incremented for ${widget.documentSnapshot.id}");
    } catch (e) {
      print("Error incrementing counter: $e");
    }
  }

  Future<void> _fetchReviews() async {
    try {
      // Stream to fetch reviews from Firestore
      Stream<QuerySnapshot<Map<String, dynamic>>> _reviewsStream = _firestore
          .collection('Review')
          .where('foodTruckId', isEqualTo: widget.documentSnapshot.id)
          .snapshots();

      // Listening to the stream
      _reviewsStream
          .listen((QuerySnapshot<Map<String, dynamic>> reviewsSnapshot) {
        if (reviewsSnapshot.docs.isNotEmpty) {
          double totalRating = 0.0;
          int count = reviewsSnapshot.docs.length;

          for (var doc in reviewsSnapshot.docs) {
            // Safely parse the rating from Firestore
            double rating =
                double.tryParse(doc.data()['rating'].toString()) ?? 0.0;
            totalRating += rating;
          }

          // Update the UI with calculated values
          setState(() {
            averageRating = totalRating / count;
            reviewsCount = count;
          });
        } else {
          // Handle case with no reviews
          setState(() {
            averageRating = 0.0;
            reviewsCount = 0;
          });
        }
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 252, 252, 253),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: viewLocationAndAddToFavoriteButton(),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: widget.documentSnapshot['truckImage'],
                        child: Container(
                          height: MediaQuery.of(context).size.height / 2.1,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                widget.documentSnapshot['truckImage'],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 380,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 252, 252, 253),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      width: 40,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    widget.documentSnapshot['businessLogo'],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.documentSnapshot['name'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.restaurant_menu,
                              size: 19,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              categoryName,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              "         ",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.grey,
                              ),
                            ),
                            const Icon(
                              Iconsax.clock,
                              size: 19,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${widget.documentSnapshot['operatingHours']}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.star1,
                              color: Colors.amberAccent,
                            ),
                            Text("5/"),
                            Text(
                              averageRating.toStringAsFixed(
                                  1), // Correctly display the average rating
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "( $reviewsCount تقييم )", // Correctly display the review count
                              style: TextStyle(
                                color: Color.fromARGB(255, 163, 163, 163),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Text(
                              "قائمة الطعام",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                        Column(
                          children:
                              (widget.documentSnapshot['item_images_list'] !=
                                          null
                                      ? widget
                                          .documentSnapshot['item_images_list']
                                      : [])
                                  .asMap()
                                  .entries
                                  .map<Widget>((entry) {
                            int index = entry.key;
                            String imageUrl = entry.value;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(8),
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  const BoxShadow(
                                    color: Color.fromARGB(31, 154, 154, 154),
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 245, 245, 245),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(imageUrl),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      (widget.documentSnapshot[
                                                  'item_names_list'] !=
                                              null
                                          ? widget.documentSnapshot[
                                              'item_names_list']
                                          : [])[index],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Row(
                                      children: [
                                        Text(
                                          (widget.documentSnapshot[
                                                      'item_prices_list'] !=
                                                  null
                                              ? widget.documentSnapshot[
                                                      'item_prices_list'][index]
                                                  .toString()
                                              : "0"),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Image.asset(
                                          'assets/images/Riyal.png',
                                          width: 15,
                                          height: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Positioned(
            //   top: 25,
            //   left: 11,
            //   right: 11,
            //   child: Row(
            //     children: [
            //       MyIconButton(
            //         icon: Icons.arrow_back_ios_new,
            //         pressed: () {
            //           Navigator.pop(context);
            //         },
            //       ),
            //       const Spacer(),
            //       // MyIconButton(icon: Iconsax.notification, pressed: () {})
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // load the category name based on the categoryId
  Future<void> _loadCategoryName() async {
    final categoryId = widget.documentSnapshot['categoryId'];
    final name = await getCategoryNameById(categoryId);
    setState(() {
      categoryName = name;
    });
  }

  // Fetch category name by categoryId from Firestore
  Future<String> getCategoryNameById(String categoryId) async {
    try {
      final categoryDoc =
          await _firestore.collection('Food-Category').doc(categoryId).get();

      if (categoryDoc.exists) {
        return categoryDoc['name'] ?? 'Unknown Category';
      } else {
        return 'Unknown Category';
      }
    } catch (e) {
      print('Error fetching category name: $e');
      return 'Error loading category';
    }
  }

  Future<void> _checkIfFavorite() async {
    final user = _auth.currentUser;
    if (user != null) {
      final favDoc = await _firestore
          .collection('Favorite')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.documentSnapshot.id)
          .get();
      setState(() {
        isFavorite = favDoc.exists;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = _auth.currentUser;
    if (user != null) {
      final favRef = _firestore
          .collection('Favorite')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.documentSnapshot.id);

      if (isFavorite) {
        // Remove from favorites
        await favRef.delete();
      } else {
        // Add to favorites
        await favRef.set({
          'truckId': widget.documentSnapshot.id,
          'truckName': widget.documentSnapshot['name'],
          'truckImage': widget.documentSnapshot['truckImage'],
          'businessLogo': widget.documentSnapshot['businessLogo'],
          'category': categoryName,
          'operatingHours': widget.documentSnapshot['operatingHours'],
          'location':
              widget.documentSnapshot.data().toString().contains('location')
                  ? widget.documentSnapshot['location']
                  : null,
        });
      }
      setState(() {
        isFavorite = !isFavorite;
      });
    }
  }

  FloatingActionButton viewLocationAndAddToFavoriteButton() {
    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {},
      label: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              String location = widget.documentSnapshot['location'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmbeddedMap(
                    destination: location, // Pass the location string
                    customerID: widget.customerID, // Pass the customer ID
                    documentID: widget
                        .documentSnapshot.id, // Pass the food truck document ID
                  ),
                ),
              );
            },
            child: Text(
              "عرض الموقع",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => //the passed parameter
                      CustomerReviews(
                    truckID: widget.documentSnapshot.id,
                    customerID: widget.customerID,
                  ),
                ),
              );
            },
            child: Text(
              "تقييم",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kBannerColor, width: 1),
            ),
            child: InkWell(
              onTap: _toggleFavorite,
              child: Icon(
                isFavorite ? Iconsax.heart5 : Iconsax.heart,
                color: isFavorite
                    ? const Color.fromARGB(255, 204, 73, 63)
                    : Colors.black,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
