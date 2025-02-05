import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'dart:ui' as ui;

class OwnerReviews extends StatelessWidget {
  final String ownerID;

  const OwnerReviews({Key? key, required this.ownerID}) : super(key: key);

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
            icon: Icons.arrow_forward_ios,
            pressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Review')
            .where('foodTruckId', isEqualTo: ownerID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ ما'));
          }

          var reviews = snapshot.data?.docs ?? [];
          double totalRating = 0;
          for (var review in reviews) {
            totalRating +=
                double.tryParse(review['rating']?.toString() ?? '0') ?? 0.0;
          }
          double averageRating =
              reviews.isNotEmpty ? totalRating / reviews.length : 0.0;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        averageRating.toStringAsFixed(1),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Center(
                        child: RatingBarIndicator(
                          rating: averageRating,
                          itemBuilder: (context, _) => const Icon(
                            Iconsax.star1,
                            color: kBannerColor,
                          ),
                          itemCount: 5,
                          itemSize: 50.0,
                          direction: Axis.horizontal,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'عدد التقييمات: ${reviews.length}',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (reviews.isEmpty)
                        const Center(
                          child: Text(
                            'لا توجد تقييمات على هذه العربة',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            children: reviews.map((doc) {
                              var commentData =
                                  doc.data() as Map<String, dynamic>;
                              return buildCommentCard(commentData);
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildCommentCard(Map<String, dynamic> commentData) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Customer')
          .doc(commentData['customerId'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('حدث خطأ في تحميل بيانات العميل'));
        }

        String customerName = 'اسم المستخدم';
        if (snapshot.hasData && snapshot.data!.exists) {
          var customerData = snapshot.data!.data() as Map<String, dynamic>;
          customerName = customerData['Name'] ?? 'اسم المستخدم';
        }

        String formattedTimestamp = 'غير متوفر';
        if (commentData['timestamp'] != null) {
          try {
            DateTime timestamp = DateTime.parse(commentData['timestamp']);
            formattedTimestamp = DateFormat('dd/MM/yyyy').format(timestamp);
          } catch (e) {
            formattedTimestamp = 'تنسيق غير صالح';
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  textDirection: ui.TextDirection.rtl, //1
                  children: [
                    Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 84, 84, 84),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: commentData['avatarUrl'] != null &&
                                commentData['avatarUrl'].isNotEmpty
                            ? NetworkImage(commentData['avatarUrl'])
                            : AssetImage('assets/images/user.png')
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: ui.TextDirection.rtl, //2
                        children: [
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formattedTimestamp,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RatingBar.builder(
                      initialRating:
                          double.tryParse(commentData['rating'] ?? '0') ?? 0.0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 20,
                      itemBuilder: (context, _) => const Icon(
                        Iconsax.star1,
                        color: kBannerColor,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  commentData['comment'] ?? 'لا توجد تفاصيل',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
