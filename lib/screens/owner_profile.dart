import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/menu_update.dart';
import 'package:tracki/screens/owner_home_screen.dart';
import 'package:tracki/screens/owner_main_screen.dart';
import 'package:tracki/screens/truck_details_update.dart';

import 'package:tracki/widgets/my_icon_button.dart';

class OwnerProfile extends StatefulWidget {
  final String ownerID;

  const OwnerProfile({Key? key, required this.ownerID}) : super(key: key);

  @override
  _OwnerProfileState createState() => _OwnerProfileState();
}

class _OwnerProfileState extends State<OwnerProfile> {
  String categoryName = '';

  @override
  void initState() {
    super.initState();
    _loadCategoryName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const SizedBox(width: 15),
          MyIconButton(
            icon: Iconsax.user_edit,
            pressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TruckDetailsUpdate(
                    ownerID: widget.ownerID,
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          MyIconButton(
            icon: Icons.arrow_forward_ios,
            pressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OwnerMainScreen(
                    ownerID: widget.ownerID,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getOwnerFoodTruckData(widget.ownerID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          } else {
            final truckData = snapshot.data!;
            final logoUrl = truckData['businessLogo'] ?? '';
            final truckName = truckData['name'] ?? 'Unnamed Truck';
            final truckDescription =
                truckData['description'] ?? 'No description available';
            final rating = truckData['rating'] ?? 0.0;
            final ratingsCount = truckData['ratingsCount'] ?? 0;
            final itemImagesList =
                truckData['item_images_list'] as List<dynamic>? ?? [];
            final itemNamesList =
                truckData['item_names_list'] as List<dynamic>? ?? [];
            final itemPricesList =
                truckData['item_prices_list'] as List<dynamic>? ?? [];
            final itemCount = itemNamesList.length;
            final operatingHours =
                truckData['operatingHours'] ?? 'No hours available';

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 400,
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(255, 75, 48, 92), // Purple
                          kBannerColor, // Blue
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        if (logoUrl.isNotEmpty)
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(logoUrl),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          truckName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.restaurant_menu,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              operatingHours,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Iconsax.clock,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  rating.toString(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'التقييم',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  ratingsCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'التقييمات',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  itemCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'الأصناف',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'وصف العربة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  // Truck Description Section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Description card
                        Container(
                          width: 385,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 231, 231, 231),
                            ),
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(110, 225, 217, 231),
                                blurRadius: 5,
                                spreadRadius: 0.2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              truckDescription,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        ' محتويات قائمة الطعام ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Menu List
                  if (itemNamesList.isEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Image.asset(
                          'assets/images/emptyState.png',
                          width: 230, // Adjust width as needed
                          height: 230, // Adjust height as needed
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuUpdate(
                                  ownerID: widget.ownerID,
                                ),
                              ),
                            );
                          },
                          child: const Text('أضف أصناف'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBannerColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                  else
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: itemNamesList.length,
                      itemBuilder: (context, index) {
                        final imageUrl = itemImagesList.isNotEmpty
                            ? itemImagesList[index]
                            : 'https://via.placeholder.com/50';
                        final itemName = itemNamesList[index];
                        final itemPrice = itemPricesList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 15.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(110, 225, 217, 231),
                                  blurRadius: 5,
                                  spreadRadius: 0.2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: FadeInImage.assetNetwork(
                                    placeholder:
                                        'assets/images/placeholder-image.jpg',
                                    image: imageUrl,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/placeholder-image.jpg',
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      itemName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline
                                      .alphabetic, // Required when using baseline alignment
                                  children: [
                                    Baseline(
                                      baseline:
                                          16, // This should match the font size or be visually adjusted
                                      baselineType: TextBaseline.alphabetic,
                                      child: Image.asset(
                                        'assets/images/Riyal.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      '$itemPrice',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 60),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _loadCategoryName() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .doc(widget.ownerID)
          .get();

      if (snapshot.exists) {
        final categoryId = snapshot.data()?['categoryId'] ?? '';
        final name = await getCategoryNameById(categoryId);
        setState(() {
          categoryName = name;
        });
      }
    } catch (e) {
      print('Error loading category name: $e');
      setState(() {
        categoryName = 'Unknown Category';
      });
    }
  }

  Future<String> getCategoryNameById(String categoryId) async {
    try {
      final categoryDoc = await FirebaseFirestore.instance
          .collection('Food-Category')
          .doc(categoryId)
          .get();

      if (categoryDoc.exists) {
        return categoryDoc.data()?['name'] ?? 'Unknown Category';
      } else {
        return 'Unknown Category';
      }
    } catch (e) {
      print('Error fetching category name: $e');
      return 'Error loading category';
    }
  }

  Future<Map<String, dynamic>> getOwnerFoodTruckData(String docId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .doc(docId)
          .get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching food truck data: $e');
      return {};
    }
  }
}
