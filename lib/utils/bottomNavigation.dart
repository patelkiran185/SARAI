import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: WaterDropNavBar(
        backgroundColor: Colors.blue,
        waterDropColor: const Color.fromARGB(255, 247, 240, 240).withOpacity(0.8), 
        inactiveIconColor: Colors.white,
        iconSize: 30,
        bottomPadding: 15,
        barItems: [
          BarItem(
            filledIcon: Icons.home,
            outlinedIcon: Icons.home_outlined,
          ),
          BarItem(
            filledIcon: Icons.search,
            outlinedIcon: Icons.search_outlined,
          ),
          BarItem(
            filledIcon: Icons.notifications,
            outlinedIcon: Icons.notifications_outlined,
          ),
          BarItem(
            filledIcon: Icons.settings,
            outlinedIcon: Icons.settings_outlined,
          ),
        ],
        selectedIndex: currentIndex,
        onItemSelected: onItemSelected,
      ),
    );
  }
}