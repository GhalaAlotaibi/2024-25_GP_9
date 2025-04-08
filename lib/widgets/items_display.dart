import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:tracki/screens/food_truck_profile_display.dart';

class ItemsDisplay extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  final customerID;
  const ItemsDisplay(
      {super.key, required this.documentSnapshot, required this.customerID});

  @override
  State<ItemsDisplay> createState() => _ItemsDisplayState();
} //FoodTruckProfileDisplay

class _ItemsDisplayState extends State<ItemsDisplay> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference requestCollection =
      FirebaseFirestore.instance.collection("Request");

  bool isFavorite = false;
  String categoryName = '';
  bool isTruckAccepted = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _loadCategoryName();
    _checkTruckStatus();
  }

// COUNTER PURPOSE
  Future<void> _incrementViewCounter() async {
    try {
      await _firestore
          .collection('Food_Truck')
          .doc(widget.documentSnapshot.id)
          .update({'TruckCounter': FieldValue.increment(1)});
    } catch (e) {
      print('Error incrementing view counter: $e');
    }
  }

  Future<void> _checkTruckStatus() async {
    final statusId = widget.documentSnapshot['statusId'];
    try {
      final requestDoc = await requestCollection.doc(statusId).get();

      if (requestDoc.exists && requestDoc['status'] == 'accepted') {
        setState(() {
          isTruckAccepted = true;
        });
      } else {
        setState(() {
          isTruckAccepted = false;
        });
      }
    } catch (e) {
      print('Error checking truck status: $e');
      setState(() {
        isTruckAccepted = false; // In case of any error, default to false
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final favDoc = await _firestore
            .collection('Favorite')
            .doc(user.uid)
            .collection('favorites')
            .doc(widget.documentSnapshot.id)
            .get();

        if (mounted) {
          setState(() {
            isFavorite = favDoc.exists;
          });
        }
      } catch (e) {
        print('Error checking favorite status: $e');
      }
    }
  }

  Future<void> _loadCategoryName() async {
    final categoryId = widget.documentSnapshot['categoryId'];
    try {
      final name = await getCategoryNameById(categoryId);

      if (mounted) {
        setState(() {
          categoryName = name;
        });
      }
    } catch (e) {
      print('Error loading category name: $e');
    }
  }

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

  Future<void> _toggleFavorite() async {
    final user = _auth.currentUser;
    if (user != null) {
      final favRef = _firestore
          .collection('Favorite')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.documentSnapshot.id);

      if (isFavorite) {
        await favRef.delete();
      } else {
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

  @override
  Widget build(BuildContext context) {
    // Check if the truck status is "accepted"
    if (!isTruckAccepted) {
      return SizedBox
          .shrink(); // Return an empty widget if truck is not accepted
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: () {
          _incrementViewCounter(); // COUNTER RELATED
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodTruckProfileDisplay(
                  documentSnapshot: widget.documentSnapshot,
                  customerID: widget.customerID),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(left: 10),
          width: 230,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag:
                              '${widget.documentSnapshot.id}_${widget.documentSnapshot["truckImage"]}',
                          child: Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12)),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  widget.documentSnapshot["truckImage"],
                                ),
                              ),
                            ),
                          ),
                        ), //
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                              255, 255, 255, 255)
                                          .withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    widget.documentSnapshot["businessLogo"],
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.documentSnapshot["name"],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.restaurant_menu,
                                size: 15,
                                color: Color.fromARGB(255, 113, 113, 113),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                categoryName,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 113, 113, 113),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text("  ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color.fromARGB(255, 113, 113, 113),
                                  )),
                              const Icon(
                                Iconsax.clock,
                                size: 16,
                                color: Color.fromARGB(255, 113, 113, 113),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${widget.documentSnapshot['operatingHours']} ",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 113, 113, 113),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 5,
                left: 5,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: InkWell(
                    onTap: _toggleFavorite,
                    child: Icon(
                      isFavorite ? Iconsax.heart5 : Iconsax.heart,
                      color: isFavorite
                          ? const Color.fromARGB(255, 204, 73, 63)
                          : Colors.black,
                      size: 20,
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
}
