import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/items_display_right.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'add_item.dart';
import 'edit_item.dart';
import 'owner_main_screen.dart'; // Import OwnerMainScreen

class TruckProfile extends StatefulWidget {
  final String truckId;

  const TruckProfile({Key? key, required this.truckId}) : super(key: key);

  @override
  _TruckProfileState createState() => _TruckProfileState();
}

class _TruckProfileState extends State<TruckProfile> {
  DocumentSnapshot? truckData;

  @override
  void initState() {
    super.initState();
    fetchTruckData();
  }

  void fetchTruckData() async {
    try {
      truckData = await FirebaseFirestore.instance
          .collection("Food_Truck")
          .doc(widget.truckId)
          .get();

      if (!truckData!.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Truck not found.")),
        );
        Navigator.pop(context);
      } else {
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching truck data: $e")),
      );
      print("Error fetching truck data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 241, 247, 1),
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const SizedBox(width: 15),
          MyIconButton(
            icon: Icons.arrow_back_ios_new,
            pressed: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          Center(
            child: const Text(
              "",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
        ],
      ),
      body: truckData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /*
                  ItemsDisplayRight(documentSnapshot: truckData!),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Iconsax.star1,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        truckData!['rating'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(" / 5"),
                      const SizedBox(width: 5),
                      Text(
                        "(${truckData!['ratingsCount']} تقييمات)",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 163, 163, 163),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      truckData!['description'],
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.right,
                    ),
                    trailing: const Icon(Icons.description),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      truckData!['location'],
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.right,
                    ),
                    trailing: const Icon(Icons.location_on),
                  ),
                  const SizedBox(height: 30),
*/
                  // Menu Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddItem(truckId: widget.truckId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBannerColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add_circle_outline,
                                color: Colors.white), // Add Icon for the button
                            SizedBox(width: 8), // Space between icon and text
                            Text(
                              "إضافة صنف",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "قائمة الطعام",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Menu Items
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: truckData!['item_names_list'].length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditItem(
                                        truckId: widget.truckId,
                                        itemName: truckData!['item_names_list']
                                            [index],
                                        itemPrice:
                                            truckData!['item_prices_list']
                                                [index],
                                        itemImage:
                                            truckData!['item_images_list']
                                                [index],
                                        itemIndex: index,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      truckData!['item_names_list'][index],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.right,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'ريال',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          "${truckData!['item_prices_list'][index]} ",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  truckData!['item_images_list'][index],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Add the new button to navigate to OwnerMainScreen
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OwnerMainScreen(
                            ownerID: widget.truckId, // Pass truckId as ownerID
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBannerColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "انتهيت",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
