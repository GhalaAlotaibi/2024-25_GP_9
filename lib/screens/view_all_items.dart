import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/food_truck_profile_display.dart';
import 'package:tracki/widgets/my_icon_button.dart';

class ViewAllItems extends StatefulWidget {
  final String customerID;
  const ViewAllItems({super.key, required this.customerID});

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

class _ViewAllItemsState extends State<ViewAllItems> {
  final CollectionReference completeListOfTrucks =
      FirebaseFirestore.instance.collection("Food_Truck");
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection("Food-Category");
  final CollectionReference requestCollection =
      FirebaseFirestore.instance.collection("Request");

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const SizedBox(width: 20),
          const Spacer(),
          const Text(
            "العربات",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 105),
          // const Spacer(),
          MyIconButton(
              icon: Icons.arrow_forward_ios,
              pressed: () {
                Navigator.pop(context);
              }),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            mySearchBar(),
            StreamBuilder(
              stream: completeListOfTrucks.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  final filteredDocs = streamSnapshot.data!.docs.where((doc) {
                    final truckName = doc['name'].toString().toLowerCase();
                    return truckName.contains(searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          filteredDocs[index];

                      String uniqueId =
                          '${documentSnapshot.id}_${documentSnapshot["name"]}';

                      // Fetch statusId from the truck's document
                      String statusId = documentSnapshot['statusId'];

                      // Fetch the associated request document based on statusId
                      return FutureBuilder<DocumentSnapshot>(
                        future: requestCollection.doc(statusId).get(),
                        builder: (context, requestSnapshot) {
                          if (requestSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (requestSnapshot.hasData &&
                              requestSnapshot.data != null) {
                            // Check the status of the request
                            String status = requestSnapshot.data!['status'];

                            // Only display the truck if the status is 'accepted'
                            if (status == 'accepted') {
                              // Fetch category name by categoryId
                              return FutureBuilder<DocumentSnapshot>(
                                future: categoriesCollection
                                    .doc(documentSnapshot['categoryId'])
                                    .get(),
                                builder: (context, categorySnapshot) {
                                  if (categorySnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (categorySnapshot.hasData &&
                                      categorySnapshot.data != null) {
                                    // Get the category name from the category document
                                    String categoryName =
                                        categorySnapshot.data!['name'];

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FoodTruckProfileDisplay(
                                                    documentSnapshot:
                                                        documentSnapshot,
                                                    customerID:
                                                        widget.customerID),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              spreadRadius: 2,
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Hero(
                                                  tag:
                                                      '${documentSnapshot.id}_${documentSnapshot['truckImage']}', // Unique tag
                                                  child: Container(
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(12),
                                                        topRight:
                                                            Radius.circular(12),
                                                      ),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                          documentSnapshot[
                                                              "truckImage"],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 7),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          const SizedBox(
                                                              width: 10),
                                                          Text(
                                                            documentSnapshot[
                                                                "name"],
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          180,
                                                                          180,
                                                                          180)
                                                                      .withOpacity(
                                                                          0.20),
                                                                  spreadRadius:
                                                                      2,
                                                                  blurRadius: 5,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 2),
                                                                ),
                                                              ],
                                                            ),
                                                            child: ClipOval(
                                                              child:
                                                                  Image.network(
                                                                documentSnapshot[
                                                                    "businessLogo"],
                                                                width: 60,
                                                                height: 60,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            "${documentSnapshot['operatingHours']} ",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          const Icon(
                                                            Iconsax.clock,
                                                            size: 20,
                                                            color: Colors.grey,
                                                          ),
                                                          const Text(
                                                            "          ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          Text(
                                                            categoryName, // Display the category name here
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          const Icon(
                                                            Icons
                                                                .restaurant_menu,
                                                            size: 20,
                                                            color: Colors.grey,
                                                          ),
                                                          const SizedBox(
                                                              width: 15),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            "( ${documentSnapshot['ratingsCount']} عدد التقييمات )",
                                                            style: const TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        163,
                                                                        163,
                                                                        163),
                                                                fontSize: 11),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                            documentSnapshot[
                                                                'rating'],
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const Text("/5"),
                                                          const SizedBox(
                                                              width: 5),
                                                          const Icon(
                                                            Iconsax.star1,
                                                            color: Colors
                                                                .amberAccent,
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                        ],
                                                      )
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
                                                  onTap: () {},
                                                  child: const Icon(
                                                    Iconsax.heart,
                                                    color: Colors.black,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              );
                            } else {
                              return const SizedBox(); // Skip truck if status is not 'accepted'
                            }
                          } else {
                            return const SizedBox();
                          }
                        },
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Padding mySearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
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
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
