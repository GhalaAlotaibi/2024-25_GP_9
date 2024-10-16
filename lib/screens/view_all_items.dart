import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/items_display.dart';
import 'package:tracki/widgets/my_icon_button.dart';

class ViewAllItems extends StatefulWidget {
  const ViewAllItems({super.key});

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

//This page is used for displaying all the registered food trucks
class _ViewAllItemsState extends State<ViewAllItems> {
  final CollectionReference completeListOfTrucks =
      FirebaseFirestore.instance.collection("Food_Truck");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const SizedBox(
            width: 15,
          ),
          MyIconButton(

              //Should be used throughout all the pages
              icon: Icons.arrow_back_ios_new,
              pressed: () {
                Navigator.pop(context);
              }),
          const Spacer(),
          const Text(
            "العربات",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          MyIconButton(icon: Iconsax.notification, pressed: () {}),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 5, left: 15),
        child: Column(
          children: [
            mySearchBar(),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: completeListOfTrucks.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> StreamSnapshot) {
                if (StreamSnapshot.hasData) {
                  return GridView.builder(
                      itemCount: StreamSnapshot.data!.docs.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 0.7),
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                            StreamSnapshot.data!.docs[index];
                        return Column(
                          //Overflow here
                          children: [
                            ItemsDisplay(documentSnapshot: documentSnapshot),
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.star1,
                                  color: Colors.amberAccent,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  documentSnapshot['rating'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text("/5"),
                                const SizedBox(width: 5),
                                Text(
                                  "${documentSnapshot['ratingsCount']} reviews",
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 163, 163, 163),
                                      fontSize: 11),
                                )
                              ],
                            )
                          ],
                        );
                      });
                }
                return const Center(child: CircularProgressIndicator());
              },
            )
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
}
