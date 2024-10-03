import 'package:flutter/material.dart';
import 'package:sarai/utils/bottomNavigation.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Colors.blue, // Set background color to blue
        iconTheme: IconThemeData(color: Colors.white), centerTitle: true, // Set icon color to white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileSection(),
            SizedBox(height: 20),
            _buildSettingsItem('Account', Icons.person, 'Manage your profile and preferences'),
            _buildSettingsItem('Notifications', Icons.notifications, 'Configure your alert settings'),
            _buildSettingsItem('Privacy & Security', Icons.security, 'Control your data and access'),
            _buildSettingsItem('Help & Support', Icons.help, 'Get assistance and FAQs'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3, // Assuming Settings is the 4th tab
        onItemSelected: (index) {
          // Handle navigation based on the selected index
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/alerts');
              break;
            case 3:
              // Already on settings screen
              break;
          }
        },
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/profile.jpg'),
        ),
        title: Text('John Doe'),
        subtitle: Text('john.doe@example.com'),
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, String subtitle) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle settings item tap
        },
      ),
    );
  }
}