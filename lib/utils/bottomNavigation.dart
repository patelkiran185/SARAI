// import 'package:flutter/material.dart';
// import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

// class BottomNavigation extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onItemSelected;

//   const BottomNavigation({
//     super.key,
//     required this.currentIndex,
//     required this.onItemSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         color: Colors.blue,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//       ),
//       child: WaterDropNavBar(
//         backgroundColor: Colors.blue,
//         waterDropColor: const Color.fromARGB(255, 247, 240, 240).withOpacity(0.8), 
//         inactiveIconColor: Colors.white,
//         iconSize: 30,
//         bottomPadding: 15,
//         barItems: [
//           BarItem(
//             filledIcon: Icons.home,
//             outlinedIcon: Icons.home_outlined,
//           ),
//           BarItem(
//             filledIcon: Icons.search,
//             outlinedIcon: Icons.search_outlined,
//           ),
//           BarItem(
//             filledIcon: Icons.notifications,
//             outlinedIcon: Icons.notifications_outlined,
//           ),
//           BarItem(
//             filledIcon: Icons.settings,
//             outlinedIcon: Icons.settings_outlined,
//           ),
//         ],
//         selectedIndex: currentIndex,
//         onItemSelected: onItemSelected,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'dart:ui';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // borderRadius: const BorderRadius.only(
      //   topLeft: Radius.circular(20),
      //   topRight: Radius.circular(20),
      // ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue, // Semi-transparent blue
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent, 
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white, 
            unselectedItemColor: Colors.white70, 
            currentIndex: currentIndex,
            onTap: onItemSelected,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
