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

//Updated(add), -Buth ----------------------------------------------------------------
  Future<void> _checkIfFavorite() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Check if the truck is in the user's favorites
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

        // 🔥 NEW: Sync to Favorite_Notif subcollection if favorited
        final favNotifRef = _firestore
            .collection('Favorite_Notif')
            .doc(user.uid)
            .collection('favorited_trucks')
            .doc(widget.documentSnapshot.id);

        if (favDoc.exists) {
          // Add/update the truck in Favorite_Notif
          await favNotifRef.set({
            'truckId': widget.documentSnapshot.id,
            'location': widget.documentSnapshot['location'],
            'timestamp':
                FieldValue.serverTimestamp(), // Optional: track when favorited
          });
        } else {
          // If un-favorited, remove from Favorite_Notif
          await favNotifRef.delete();
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

//Updated(delete), -Buth --------------------------------------------------------------
  Future<void> _toggleFavorite() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final truckId = widget.documentSnapshot.id;
      final truckData =
          widget.documentSnapshot.data() as Map<String, dynamic>? ?? {};

      // 1. Reference both Firestore paths
      final favRef = _firestore
          .collection('Favorite')
          .doc(user.uid)
          .collection('favorites')
          .doc(truckId);

      final favNotifRef = _firestore
          .collection('Favorite_Notif')
          .doc(user.uid)
          .collection('favorited_trucks')
          .doc(truckId);

      // 2. Toggle favorite status
      if (isFavorite) {
        // Remove from BOTH collections
        await Future.wait([
          favRef.delete(),
          favNotifRef.delete(),
        ]);
      } else {
        // Add to BOTH collections
        final truckDetails = {
          'truckId': truckId,
          'truckName': truckData['name'] ?? 'No name',
          'truckImage': truckData['truckImage'] ?? '',
          'businessLogo': truckData['businessLogo'] ?? '',
          'category': categoryName,
          'operatingHours': truckData['operatingHours'] ?? 'Not specified',
          'location': truckData['location'] ?? null,
          'timestamp': FieldValue.serverTimestamp(), // Track when favorited
        };

        await Future.wait([
          favRef.set(truckDetails),
          favNotifRef.set(truckDetails),
        ]);
      }

      // 3. Update UI
      if (mounted) {
        setState(() => isFavorite = !isFavorite);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Optional: Revert UI state or show error
      if (mounted) {
        setState(() => isFavorite = isFavorite); // Revert if failed
      }
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
