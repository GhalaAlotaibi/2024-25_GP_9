import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/customer_reviews.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'package:tracki/screens/owner_reviews.dart'; // Make sure to import your OwnerReviews page
import 'package:tracki/screens/profile_map.dart';

class FoodTruckProfileDisplay extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const FoodTruckProfileDisplay({super.key, required this.documentSnapshot});

  @override
  State<FoodTruckProfileDisplay> createState() =>
      _FoodTruckProfileDisplayState();
}

class _FoodTruckProfileDisplayState extends State<FoodTruckProfileDisplay> {
  @override
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
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
          'category': widget.documentSnapshot['category'],
          'operatingHours': widget.documentSnapshot['operatingHours'],
        });
      }
      setState(() {
        isFavorite = !isFavorite;
      });
    }
  }

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
                              "${widget.documentSnapshot['category']}",
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
                            const SizedBox(width: 10),
                            const Icon(
                              Iconsax.star1,
                              color: Colors.amberAccent,
                            ),
                            const Text("5/"),
                            Text(
                              widget.documentSnapshot['rating'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "( ${widget.documentSnapshot['ratingsCount']}  تقييم )",
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
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  const BoxShadow(
                                    color: Color.fromARGB(31, 154, 154, 154),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Image container
                                  Container(
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(imageUrl),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      (widget.documentSnapshot[
                                                  'item_names_list'] !=
                                              null
                                          ? widget.documentSnapshot[
                                              'item_names_list']
                                          : [])[index],
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 5),
                                      Text(
                                        "${(widget.documentSnapshot['item_prices_list'] != null ? widget.documentSnapshot['item_prices_list'] : [])[index]} ريال",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 113, 113, 113),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
            Positioned(
              top: 25,
              left: 11,
              right: 11,
              child: Row(
                children: [
                  MyIconButton(
                    icon: Icons.arrow_back_ios_new,
                    pressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  // MyIconButton(icon: Iconsax.notification, pressed: () {})
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                  builder: (context) => ProfileMap(location: location),
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
                  builder: (context) =>
                      CustomerReviews(ownerID: widget.documentSnapshot.id),
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
