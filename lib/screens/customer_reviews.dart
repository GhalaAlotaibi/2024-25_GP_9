import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import 'dart:ui' as ui;

class CustomerReviews extends StatefulWidget {
  final String truckID;
  final String customerID;
  const CustomerReviews(
      {Key? key, required this.truckID, required this.customerID})
      : super(key: key);

  @override
  State<CustomerReviews> createState() => _CustomerReviewsState();
}

class _CustomerReviewsState extends State<CustomerReviews> {
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
            .where('foodTruckId', isEqualTo: widget.truckID)
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kprimaryColor,
                      minimumSize: const Size(220, 50),
                    ),
                    onPressed: () {
                      _showReviewDialog(context);
                    },
                    child: const Text(
                      'أضف تقييم',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
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

  void _showReviewDialog(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          title: const Center(
            child: Text(
              'إضافة تقييم',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 35.0,
                itemBuilder: (context, _) => const Icon(
                  Iconsax.star1,
                  color: kBannerColor,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: '...أكتب تقييمك هنا',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 10),
          actions: [
            SizedBox(
              width: 110,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('إلغاء'),
              ),
            ),
            SizedBox(
              width: 110,
              child: ElevatedButton(
                onPressed: () async {
                  if (commentController.text.isNotEmpty) {
                    if (mounted) {
                      FocusScope.of(context).unfocus();
                    }

                    await FirebaseFirestore.instance.collection('Review').add({
                      'comment': commentController.text,
                      'customerId': widget.customerID,
                      'foodTruckId': widget.truckID,
                      'rating': rating.toString(),
                      'timestamp': DateTime.now().toIso8601String(),
                    });

                    await _updateFoodTruckRating(widget.truckID);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: kBannerColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('إضافة'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateFoodTruckRating(String truckID) async {
    try {
      QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
          .collection('Review')
          .where('foodTruckId', isEqualTo: truckID)
          .get();

      double totalRating = 0;
      int reviewCount = reviewSnapshot.docs.length;

      for (var doc in reviewSnapshot.docs) {
        totalRating += double.tryParse(doc['rating'] ?? '0') ?? 0.0;
      }

      double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0.0;

      await FirebaseFirestore.instance
          .collection('Food_Truck')
          .doc(truckID)
          .update({
        'rating': averageRating.toStringAsFixed(1),
        'ratingsCount': reviewCount,
      });
    } catch (e) {
      debugPrint('Error updating food truck rating: $e');
    }
  }
}
