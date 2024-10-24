import 'package:flutter/material.dart';
import 'package:sarai/utils/bottomNavigation.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _currentIndex = 1; // Assuming Search is the 2nd tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Colors.blue, // Set background color to blue
        iconTheme: const IconThemeData(color: Colors.white), centerTitle: true, // Set icon color to white
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search SAR data, analyses, locations...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                Chip(label: Text('Flood detection')),
                Chip(label: Text('Crop health')),
                Chip(label: Text('Soil moisture')),
              ],
            ),
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.red),
                    title: Text('Flood Area'),
                    subtitle: Text('Detected on May 15, 2023'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.agriculture, color: Colors.green),
                    title: Text('Crop Cycle'),
                    subtitle: Text('Wheat field analysis'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.image, color: Colors.grey),
                    title: Text('SAR Image'),
                    subtitle: Text('Captured on June 1, 2023'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              break; // Already on search screen
            case 2:
              Navigator.pushReplacementNamed(context, '/alerts');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}