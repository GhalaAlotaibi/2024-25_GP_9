import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/my_icon_button.dart';

class CustomerReviews extends StatelessWidget {
  final String ownerID;

  const CustomerReviews({Key? key, required this.ownerID}) : super(key: key);

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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Food_Truck')
            .doc(ownerID)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ ما'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('لا يوجد بيانات متاحة'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String ratingString = data['rating'] ?? '0';
          int ratingsCount = data['ratingsCount'] ?? 0;
          double rating = double.tryParse(ratingString) ?? 0.0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  rating.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Center(
                  child: RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(
                      Iconsax.star1,
                      color: kBannerColor,
                    ),
                    onRatingUpdate: (rating) {},
                    itemSize: 50.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'عدد التقييمات: $ratingsCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Food_Truck')
                        .doc(ownerID)
                        .collection('comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('حدث خطأ أثناء تحميل التعليقات'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('لا توجد تعليقات متاحة'));
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          var commentData = doc.data() as Map<String, dynamic>;
                          return buildCommentCard(commentData);
                        }).toList(),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBannerColor,
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildCommentCard(Map<String, dynamic> commentData) {
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
              textDirection: TextDirection.rtl,
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
                        : AssetImage('assets/images/user.png') as ImageProvider,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        commentData['userName'] ?? 'Sara',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        commentData['date'] ?? ' 20/10/20',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                RatingBar.builder(
                  initialRating: (commentData['rating'] ?? 0).toDouble(),
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
              commentData['text'] ?? 'لا توجد تفاصيل',
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
  }

  void _showReviewDialog(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    double rating = 3.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          title: Center(
            child: const Text(
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
                itemSize: 30.0,
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
                  hintText: '...اكتب تعليقك هنا',
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
            ElevatedButton(
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
            ElevatedButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('Food_Truck')
                      .doc(ownerID)
                      .collection('comments')
                      .add({
                    'userName': 'Sara',
                    'avatarUrl': '',
                    'text': commentController.text,
                    'rating': rating,
                    'date': DateTime.now().toIso8601String(),
                  }).then((_) {
                    Navigator.pop(context);
                    commentController.clear();
                  }).catchError((error) {
                    print('حدث خطأ: $error');
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: kBannerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
  }
}
