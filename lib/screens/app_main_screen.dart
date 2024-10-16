import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tracki/screens/my_app_home_screen.dart';
import '../Utils/constants.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;
  @override
  void initState() {
    page = [
      const MyAppHomeScreen(),
      navBarPage(Iconsax.heart5),
      navBarPage(Iconsax.map5),
      navBarPage(Iconsax.setting_21),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //the content should be here
      backgroundColor: Colors.white,

      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          iconSize: 28,
          currentIndex: selectedIndex,
          selectedItemColor: kprimaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
              color: kprimaryColor, fontWeight: FontWeight.w600),
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
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
                label: 'Favorite'),
            BottomNavigationBarItem(
                icon: Icon(selectedIndex == 2 ? Iconsax.map5 : Iconsax.map5),
                label: 'Map'),
            BottomNavigationBarItem(
                icon: Icon(selectedIndex == 3
                    ? Iconsax.setting_21
                    : Iconsax.setting_2),
                label: 'Settings'),
          ]),
      body: page[selectedIndex],
    );
  }

  navBarPage(iconName) {
    return Center(
      child: Icon(iconName, size: 100, color: kprimaryColor),
    );
  }
}
