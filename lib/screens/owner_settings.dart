import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracki/widgets/my_icon_button.dart';
import '../Utils/constants.dart'; // Assuming kbackgroundColor is defined here

class OwnerSettings extends StatefulWidget {
  final String ownerID;

  const OwnerSettings({super.key, required this.ownerID});

  @override
  _OwnerSettingsState createState() => _OwnerSettingsState();
}

class _OwnerSettingsState extends State<OwnerSettings> {
  String? truckOwnerID;
  Map<String, dynamic>? ownerData;
  bool isLocationAccessAllowed = false;
  bool isNotificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    fetchOwnerInfo();
  }

  Future<void> fetchOwnerInfo() async {
    try {
      DocumentSnapshot foodTruckSnapshot = await FirebaseFirestore.instance
          .collection('Food_Truck')
          .doc(widget.ownerID)
          .get();

      if (foodTruckSnapshot.exists) {
        truckOwnerID = foodTruckSnapshot['ownerID'];

        if (truckOwnerID != null) {
          DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
              .collection('Truck_Owner')
              .doc(truckOwnerID)
              .get();

          if (ownerSnapshot.exists) {
            setState(() {
              ownerData = ownerSnapshot.data() as Map<String, dynamic>;
            });
          } else {
            print("Owner document not found for TruckOwnerID: $truckOwnerID");
          }
        }
      } else {
        print("Food Truck document not found for ownerID: ${widget.ownerID}");
      }
    } catch (e) {
      print("Error fetching owner info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kbackgroundColor,
        elevation: 0,
        title: const Center(
          child: Text(
            "الإعدادات",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ),
        // actions: [
        //   MyIconButton(
        //     icon: Icons.arrow_forward_ios,
        //     pressed: () {
        //       Navigator.pop(context);
        //     },
        //   ),
        //   const SizedBox(width: 15),
        // ],
      ),
      body: ownerData != null
          ? Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoContainer(
                      Icons.person, "الاسم", ownerData!['Name']),
                  _buildInfoContainer(
                      Icons.email, "البريد الإلكتروني", ownerData!['Email']),
                  _buildInfoContainer(
                      Icons.phone, "رقم الهاتف", ownerData!['PhoneNum']),
                  Divider(color: Colors.grey),
                  _buildToggleSwitch(
                      "السماح بالوصول للموقع", isLocationAccessAllowed,
                      (newValue) {
                    setState(() {
                      isLocationAccessAllowed = newValue;
                    });
                  }),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildInfoContainer(IconData icon, String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          SizedBox(width: 8),
          Text(
            ":$label",
            style: TextStyle(
                fontSize: 15, color: const Color.fromARGB(255, 0, 0, 0)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 21, 21, 21)),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch(
      String label, bool currentValue, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: currentValue,
      onChanged: onChanged,
      activeColor: kBannerColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        label,
        style: TextStyle(fontSize: 16),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
