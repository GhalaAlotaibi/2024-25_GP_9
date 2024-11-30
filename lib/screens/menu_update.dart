import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/screens/truck_details_update.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'add_item.dart';
import 'edit_item.dart';
import 'owner_main_screen.dart';

class MenuUpdate extends StatefulWidget {
  final String ownerID;

  const MenuUpdate({Key? key, required this.ownerID}) : super(key: key);

  @override
  _MenuUpdateState createState() => _MenuUpdateState();
}

class _MenuUpdateState extends State<MenuUpdate> {
  void _deleteItem(int index, Map<String, dynamic> truckData) async {
    try {
      List<dynamic> itemNames = List.from(truckData['item_names_list']);
      List<dynamic> itemPrices = List.from(truckData['item_prices_list']);
      List<dynamic> itemImages = List.from(truckData['item_images_list']);

      itemNames.removeAt(index);
      itemPrices.removeAt(index);
      itemImages.removeAt(index);

      await FirebaseFirestore.instance
          .collection("Food_Truck")
          .doc(widget.ownerID)
          .update({
        'item_names_list': itemNames,
        'item_prices_list': itemPrices,
        'item_images_list': itemImages,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حذف الصنف بنجاح")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete item")),
      );
    }
  }

  void _showDeleteConfirmationDialog(
      int index, Map<String, dynamic> truckData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kbackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "تأكيد عملية الحذف",
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
          content: const Text(
            "هل أنت متأكد من رغبتك في حذف هذا الصنف؟ \n !لا يمكنك التراجع بعد التأكيد",
            style: TextStyle(
              color: Color.fromARGB(179, 0, 0, 0),
              fontSize: 16,
            ),
            textAlign: TextAlign.end,
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: kbackgroundColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'تراجع',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: kBannerColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'تآكيد',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(index, truckData);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Container(
            child: Row(
          children: [
            const SizedBox(width: 115),
            const Text(
              "تحديث قائمة الطعام ",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        )),
        actions: [
          const SizedBox(width: 0),
          MyIconButton(
            icon: Icons.arrow_forward_ios,
            pressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Food_Truck")
                  .doc(widget.ownerID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var truckData = snapshot.data!.data() as Map<String, dynamic>;

                if (truckData.isEmpty) {
                  return const Center(child: Text("Truck not found."));
                }

                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 23, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddItem(truckId: widget.ownerID),
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "إضافة صنف",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Menu Items
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: truckData['item_names_list']?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                        iconSize: 23,
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditItem(
                                                truckId: widget.ownerID,
                                                itemName:
                                                    truckData['item_names_list']
                                                        [index],
                                                itemPrice: truckData[
                                                    'item_prices_list'][index],
                                                itemImage: truckData[
                                                    'item_images_list'][index],
                                                itemIndex: index,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        iconSize: 20,
                                        icon: const Icon(Iconsax.trash4),
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                              index, truckData);
                                        },
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          truckData['item_names_list'][index],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Text('ريال',
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            Text(
                                              "${truckData['item_prices_list'][index]} ",
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      truckData['item_images_list'][index],
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Center(
                child: SizedBox(
                  width: 200, // Adjust this width as needed
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TruckDetailsUpdate(ownerID: widget.ownerID),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBannerColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "انتهيت",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
