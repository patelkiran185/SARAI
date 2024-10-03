
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/bottomNavigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _image;
    bool _isUploading = false;
  bool _isAnalyzing = false;


  @override
  void initState() {
    super.initState();
    print('HomeScreen initialized');
    _checkUserProvider();
  }

  Future<void> _checkUserProvider() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String providerId = user.providerData.first.providerId;
      print('User provider ID: $providerId');
      if (providerId == 'github.com') {
        print('GitHub user detected');
      }
      if (providerId == 'google.com') {
        print('Google user detected');
      }
    } else {
      print('No user is logged in');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    print('Showing logout dialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                print('Logout dialog canceled');
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('Logging out from dialog');
                Navigator.of(context).pop();
                _logout(context);
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }






     Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _uploadImage();
      } else {
        print('No image selected.');
      }
    });
  }
Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse('http://192.168.17.197:5000/upload'));
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        if (jsonResponse['success'] == true) {
          _showUploadSuccessMessage();
        } else {
          _showErrorDialog('Upload failed: ${jsonResponse['error']}');
        }
      } else {
        _showErrorDialog('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('An error occurred during upload: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

 void _showUploadSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image uploaded and sent to the model successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse('http://192.168.17.197:5000/analyze'));
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        if (jsonResponse['success'] == true) {
          _showResultDialog(jsonResponse['result']);
        } else {
          _showErrorDialog('Analysis failed: ${jsonResponse['error']}');
        }
      } else {
        _showErrorDialog('Failed to analyze image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('An error occurred during analysis: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Analysis Result'),
          content: Text('The image is classified as: $result'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _logout(BuildContext context) async {
    print('Logging out');
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    print('Navigating to login screen');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('SAR GenAI Analyzer', style: TextStyle(color: Colors.white)),centerTitle: true,
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1, // Aspect ratio of the grid items
                  ),
                  itemCount: 5, // Number of feature cards
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return _buildFeatureCard('SAR Image Colorization', Icons.color_lens);
                      case 1:
                        return _buildFeatureCard('Flood Area Detection', Icons.water_damage);
                      case 2:
                        return _buildFeatureCard('Crop Mapping', Icons.grass);
                      case 3:
                        return _buildFeatureCard('Historical Analysis', Icons.history);
                      case 4:
                        return _buildFeatureCard('AI Insights', Icons.lightbulb);
                      default:
                        return Container();
                    }
                  },
                ),
                SizedBox(height: 20),
                _buildAnalyzeSection(),
                SizedBox(height: 20),
                _buildRecentAnalyses(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Handle navigation here
            switch (index) {
              case 0:
                // Already on home screen
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/search');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/alerts');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/settings');
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          // Handle feature tap
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 40),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Analyze SAR Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.upload),
              label: Text(_isUploading ? 'Uploading...' : 'Tap to upload image'),
              onPressed: _isUploading ? null : _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Image'),
              onPressed: (_image != null && !_isAnalyzing) ? _analyzeImage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnalyses() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Recent Analyses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildAnalysisItem('Analysis #1', '2 hours ago'),
            _buildAnalysisItem('Analysis #2', '2 hours ago'),
            _buildAnalysisItem('Analysis #3', '2 hours ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String time) {
    return ListTile(
      title: Text(title),
      subtitle: Text(time),
      onTap: () {
        // Handle analysis item tap
      },
    );
  }
}