import 'package:flutter/material.dart';
import 'package:sarai/utils/bottomNavigation.dart';

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _currentIndex = 2; // Assuming Alerts is the 3rd tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Colors.blue, // Set background color to blue
        automaticallyImplyLeading: false, centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: Colors.red),
              title: Text('Flood Alert'),
              subtitle: Text('High risk of flooding detected in your monitored area'),
              trailing: Text('2 hours ago'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('Analysis Complete'),
              subtitle: Text('Your requested SAR image analysis is ready'),
              trailing: Text('1 day ago'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blue),
              title: Text('New Feature'),
              subtitle: Text('Try our new AI-powered crop yield prediction tool'),
              trailing: Text('3 days ago'),
            ),
          ],
        ),
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
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 2:
              break; // Already on alerts screen
            case 3:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}
