import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/screens/customer_settings.dart';

import 'package:tracki/screens/favourites_page.dart';
import 'package:tracki/screens/my_app_home_screen.dart';
import 'package:tracki/screens/Customer_map_screen.dart';

import '../Utils/constants.dart';

class AppMainScreen extends StatefulWidget {
  final String customerID;

  const AppMainScreen({super.key, required this.customerID});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;

  late final List<Widget> page;
  // ProfileScreen(customerID: widget.customerID),
  @override
  void initState() {
    page = [
      MyAppHomeScreen(customerID: widget.customerID),
      const FavoritesPage(),
      const CustomerMapScreen(),
      CustomerSettings(customerID: widget.customerID),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        iconSize: 28,
        currentIndex: selectedIndex,
        selectedItemColor: kprimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(color: kprimaryColor, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 0 ? Iconsax.home5 : Iconsax.home1),
              label: 'الرئيسية'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
              label: 'المفضلة'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 2 ? Iconsax.map5 : Iconsax.map5),
              label: 'الخريطة'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 3
                  ? Iconsax.profile_circle5
                  : Iconsax.profile_circle4),
              label: 'حسابي'),
        ],
      ),
      body: page[selectedIndex],
    );
  }

  navBarPage(iconName) {
    return Center(
      child: Icon(iconName, size: 100, color: kprimaryColor),
    );
  }
}
