import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/items_display_right.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'add_item.dart'; // Import the Add_Item page
import 'edit_item.dart';

class TruckProfile extends StatefulWidget {
  final String truckId;

  const TruckProfile({Key? key, required this.truckId}) : super(key: key);

  @override
  _TruckProfileState createState() => _TruckProfileState();
}

class _TruckProfileState extends State<TruckProfile> {
  DocumentSnapshot? truckData; // Declare truckData as nullable

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
        // Use ! to assert truckData is not null
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
          Expanded(
            child: Center(
              child: const Text(
                "ملف العربة",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
      body: truckData == null // Check if truckData is null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ItemsDisplayRight(documentSnapshot: truckData!),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        " تقييمات ",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 163, 163, 163),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        "${truckData!['ratingsCount']}", // Use ! to assert truckData is not null
                        style: const TextStyle(
                          color: Color.fromARGB(255, 163, 163, 163),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text("5/"),
                      Text(
                        truckData!['rating']
                            .toString(), // Use ! to assert truckData is not null
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Iconsax.star1,
                        color: Colors.amberAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      truckData!['description'], // Use ! to assert truckData is not null
                      textAlign: TextAlign.right,
                    ),
                    trailing: const Icon(Icons.description),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      truckData!['location'], // Use ! to assert truckData is not null
                      textAlign: TextAlign.right,
                    ),
                    trailing: const Icon(Icons.location_on),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                                            ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddItem(truckId: widget.truckId),
                            ),
                          );
                        },
                        child: const Text("إضافة عنصر"), // Button text in Arabic
                      ),
                      const Text(
                        "قائمة الطعام",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 139, 65, 174),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                 ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: truckData!['item_names_list'].length,
  itemBuilder: (context, index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
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
                      itemName: truckData!['item_names_list'][index],
                      itemPrice: truckData!['item_prices_list'][index],
                      itemImage: truckData!['item_images_list'][index],
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
                    textAlign: TextAlign.right,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('ريال'),
                      Text(
                        "${truckData!['item_prices_list'][index]} ",
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Image.network(
              truckData!['item_images_list'][index],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  },
),

                ],
              ),
            ),
    );
  }
}
