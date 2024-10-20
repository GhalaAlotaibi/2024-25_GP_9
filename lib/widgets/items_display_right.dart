import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ItemsDisplayRight extends StatelessWidget {
  final DocumentSnapshot<Object?> documentSnapshot;

  const ItemsDisplayRight({Key? key, required this.documentSnapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(
          left: 10, // Change to left margin to align to the right
        ),
        width: 230,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end, // Align items to the right
              children: [
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        documentSnapshot["truckImage"],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Align row content to the right
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      documentSnapshot["name"],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 180, 180, 180).withOpacity(0.20),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          documentSnapshot["businessLogo"],
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Align row content to the right
                  children: [
                    const Icon(
                      Icons.restaurant,
                      size: 15,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${documentSnapshot['category']}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Iconsax.clock,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${documentSnapshot['operatingHours']} ",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
