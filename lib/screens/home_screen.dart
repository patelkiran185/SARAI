import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sarai/screens/alerts.dart';
import 'package:sarai/screens/search.dart';
import 'package:sarai/screens/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../sub-screens/aiins.dart';
import '../sub-screens/cropmap.dart';
import '../sub-screens/flooddet.dart';
import '../sub-screens/hist.dart';
import '../sub-screens/imagecolrisation.dart';
import '../utils/bottomNavigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _image;
  Uint8List? _webImage;
  bool _isClassifying = false;
  String? _classificationResult;
  bool _isMenuOpen = false;

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
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                print('Logout dialog canceled');
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('Logging out from dialog');
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _classifyImageWeb();
        });
      } else {
        print('No image selected.');
      }
    } else {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          _classifyImage();
        } else {
          print('No image selected.');
        }
      });
    }
  }

  Future<void> _classifyImage() async {
    if (_image == null) return;

    setState(() {
      _isClassifying = true;
      _classificationResult = null;
    });

    try {
      List<int> imageBytes = await _image!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_URL']}/classify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _classificationResult = jsonResponse['predicted_class_name'];
        });
      } else {
        setState(() {
          _classificationResult =
              'Failed to classify image. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _classificationResult = 'An error occurred during classification: $e';
      });
    } finally {
      setState(() {
        _isClassifying = false;
      });
    }
  }

  Future<void> _classifyImageWeb() async {
    if (_webImage == null) return;

    setState(() {
      _isClassifying = true;
      _classificationResult = null;
    });

    try {
      String base64Image = base64Encode(_webImage!);

      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_URL']}/classify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _classificationResult = jsonResponse['predicted_class_name'];
        });
      } else {
        setState(() {
          _classificationResult =
              'Failed to classify image. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _classificationResult = 'An error occurred during classification: $e';
      });
    } finally {
      setState(() {
        _isClassifying = false;
      });
    }
  }

  void _clearClassification() {
    setState(() {
      _image = null;
      _webImage = null;
      _classificationResult = null;
    });
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Classification Result'),
          content: Text('The image is classified as: $result'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
    // Use kIsWeb to determine platform
    if (kIsWeb) {
      return _buildWebLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildMobileLayout() {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SAR GenAI Analyzer',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
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
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return _buildFeatureCard(
                            'SAR Image Colorization', Icons.color_lens);
                      case 1:
                        return _buildFeatureCard(
                            'Flood Area Detection', Icons.water_damage);
                      case 2:
                        return _buildFeatureCard('Crop Mapping', Icons.grass);
                      case 3:
                        return _buildFeatureCard(
                            'Historical Analysis', Icons.history);
                      case 4:
                        return _buildFeatureCard(
                            'AI Insights', Icons.lightbulb);
                      default:
                        return Container();
                    }
                  },
                ),
                const SizedBox(height: 20),
                _buildClassifySection(),
                const SizedBox(height: 20),
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
            switch (index) {
              case 0:
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

  // New web layout
  Widget _buildWebLayout() {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1024;

    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent back navigation
      },
      child: Scaffold(
        body: Row(
         children: [
  // Main Content
  Expanded(
    child: Column(
      children: [
        // Web Header
        Container(
          color: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 600), // Add left padding
                  child: Text(
                    'SARAI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(),GestureDetector(
  onTap: () {
    setState(() {
      _currentIndex = 1;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );
  },
  child: Container(
    width:500,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2), // Set a transparent white color
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.blue), // Add a border to make it more visible
    ),
    child: Row(
      children: [
        Icon(Icons.search, color: Colors.white), // Set search icon color to white
        const SizedBox(width: 8),
        Text(
          'Search',
          style: TextStyle(
            color: Colors.white, // Keep text color white
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
              const Spacer(),
              // Hamburger Menu Button
              PopupMenuButton<int>(
                icon: const Icon(Icons.menu, color: Colors.white),
                onSelected: (int result) {
                  switch (result) {
                    case 0:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AlertsScreen()),
                      );
                      break;
                    case 1:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
                      );
                      break;
                    case 2:
                      _showLogoutDialog(context);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  const PopupMenuItem<int>(
                    value: 0,
                    child: ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text('Alerts'),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content Area
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature Cards Row
                  Container(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildWebFeatureCard('SAR Image Colorization', Icons.color_lens),
                        _buildWebFeatureCard('Flood Area Detection', Icons.water_damage),
                        _buildWebFeatureCard('Crop Mapping', Icons.grass),
                        _buildWebFeatureCard('Historical Analysis', Icons.history),
                        _buildWebFeatureCard('AI Insights', Icons.lightbulb),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Classification Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Classify SAR Image',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Drag & Drop Zone
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _webImage != null
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.memory(_webImage!),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.cloud_upload, size: 48),
                                  const SizedBox(height: 16),
                                  const Text('Upload your image here'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _pickImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: const Text('Select Image'),
                                  ),
                                ],
                              ),
                        ),
                        if (_classificationResult != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Classification Result:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(_classificationResult!),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _clearClassification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                     _buildWebAnalysisItem('Analysis #1', '2 hours ago'),
                  _buildWebAnalysisItem('Analysis #2', '2 hours ago'),
                  _buildWebAnalysisItem('Analysis #3', '2 hours ago'),


                     Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.blue.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '© 2024 SARAI',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: const Text('Privacy Policy'),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Terms of Service'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),



                ],

              ),
              
            ),
          ),
        ),
      ],
    ),
  ),
],
        ),
      ),
    );
  }

  Widget _buildWebNavItem(
      IconData icon, String label, int index, Widget screen) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        // Handle navigation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : const Color.fromARGB(0, 75, 11, 11),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.blue.shade200),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.blue.shade200,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebFeatureCard(String title, IconData icon) {
    return Container(
      width: 200, // Fixed width for square cards
      margin: const EdgeInsets.symmetric(horizontal: 80),
      child: Card(
        elevation: 4, // Add card elevation for the card effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            // Handle feature navigation (same as before)
            if (title == 'SAR Image Colorization') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SARColorizationScreen()),
              );
            }
            // Add other navigation handlers...
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebAnalysisItem(String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          // Handle feature tap
          if (title == 'SAR Image Colorization') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SARColorizationScreen()),
            );
          }
          if (title == 'Flood Area Detection') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const FloodAreaDetectionScreen()),
            );
          }
          if (title == 'Crop Mapping') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CropMappingScreen()),
            );
          }
          if (title == 'Historical Analysis') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const HistoricalAnalysisScreen()),
            );
          }
          if (title == 'AI Insights') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AIInsightsScreen()),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 40),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildClassifySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Classify SAR Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_image != null || _webImage != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: kIsWeb
                        ? MemoryImage(_webImage!)
                        : FileImage(_image!) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: Text(
                  _isClassifying ? 'Classifying...' : 'Tap to classify image'),
              onPressed: _isClassifying ? null : _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (_classificationResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Classification Result:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_classificationResult!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _clearClassification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
            ],
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
            const Text('Recent Analyses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
