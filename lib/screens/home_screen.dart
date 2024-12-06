// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../sub-screens/aiins.dart';
// import '../sub-screens/cropmap.dart';
// import '../sub-screens/flooddet.dart';
// import '../sub-screens/hist.dart';
// import '../sub-screens/imagecolrisation.dart';
// import '../utils/bottomNavigation.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//   // final FirebaseAuth _auth = FirebaseAuth.instance;
//   File? _image;
//   bool _isClassifying = false;
//    String? _classificationResult;

//   @override
//   void initState() {
//     super.initState();
//     print('HomeScreen initialized');
//     _checkUserProvider();
//   }

//   Future<void> _checkUserProvider() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       String providerId = user.providerData.first.providerId;
//       print('User provider ID: $providerId');
//       if (providerId == 'github.com') {
//         print('GitHub user detected');
//       }
//       if (providerId == 'google.com') {
//         print('Google user detected');
//       }
//     } else {
//       print('No user is logged in');
//     }
//   }

//   void _showLogoutDialog(BuildContext context) {
//     print('Showing logout dialog');
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Logout'),
//           content: const Text('Are you sure you want to logout?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 print('Logout dialog canceled');
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 print('Logging out from dialog');
//                 Navigator.of(context).pop();
//                 _logout(context);
//               },
//               child: const Text('Logout'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//         _classifyImage();
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//    Future<void> _classifyImage() async {
//     if (_image == null) return;

//     setState(() {
//       _isClassifying = true;
//       _classificationResult = null;
//     });

//     try {
//       List<int> imageBytes = await _image!.readAsBytes();
//       String base64Image = base64Encode(imageBytes);

//       final response = await http.post(
//         Uri.parse('${dotenv.env['BACKEND_URL']}/classify'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'image': base64Image}),
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         setState(() {
//           _classificationResult = jsonResponse['predicted_class_name'];
//         });
//       } else {
//         setState(() {
//           _classificationResult = 'Failed to classify image. Status code: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _classificationResult = 'An error occurred during classification: $e';
//       });
//     } finally {
//       setState(() {
//         _isClassifying = false;
//       });
//     }
//   }

// void _clearClassification() {
//     setState(() {
//       _image = null;
//       _classificationResult = null;
//     });
//   }


//   void _showResultDialog(String result) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Classification Result'),
//           content: Text('The image is classified as: $result'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }


// void _showChatbot(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     isScrollControlled: true,
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('AI Chatbot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const Divider(),
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.85, 
//               child: const AIInsightsScreen(),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }



//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _logout(BuildContext context) async {
//     print('Logging out');
//     await FirebaseAuth.instance.signOut();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', false);
//     print('Navigating to login screen');
//     Navigator.of(context).pushReplacementNamed('/login');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: true,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(' SARVISION', style: TextStyle(color: Colors.white)),
//           centerTitle: true,
//           automaticallyImplyLeading: false, 
//           backgroundColor: Colors.blue,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.logout, color: Colors.white),
//               onPressed: () => _showLogoutDialog(context),
//             ),
//           ],
//         ),
//         // body: SingleChildScrollView(
//         //   child: Padding(
//         //     padding: const EdgeInsets.all(16.0),
//         //     child: Column(
//         //       crossAxisAlignment: CrossAxisAlignment.stretch,
//         //       children: [
//         //         GridView.builder(
//         //           shrinkWrap: true,
//         //           physics: const NeverScrollableScrollPhysics(),
//         //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         //             crossAxisCount: 2,
//         //             crossAxisSpacing: 8,
//         //             mainAxisSpacing: 8,
//         //             childAspectRatio: 1,
//         //           ),
//         //           itemCount: 2,
//         //           itemBuilder: (context, index) {
//         //             switch (index) {
//         //               // case 0:
//         //               //   return _buildFeatureCard('SAR Image Colorization', Icons.color_lens);
//         //               case 0:
//         //                 return _buildFeatureCard('Flood Area Detection', Icons.water_damage);
                    
//         //               default:
//         //                 return Container();
//         //             }
//         //           },
//         //         ),
//         //         const SizedBox(height: 20),
//         //         _buildClassifySection(),
                
//         //       ],
//         //     ),
//         //   ),
//         // ),
//           body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 FloodAreaDetectionCard(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const FloodAreaDetectionScreen()),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 20),
//                 // _buildClassifySection(),
               

//               ],
//             ),
//           ),
//         ),
//         bottomNavigationBar: BottomNavigation(
//           currentIndex: _currentIndex,
//           onItemSelected: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//             switch (index) {
//               case 0:
//                 break;
//               case 1:
//                 Navigator.pushReplacementNamed(context, '/search');
//                 break;
//               case 2:
//                 Navigator.pushReplacementNamed(context, '/alerts');
//                 break;
//               case 3:
//                 Navigator.pushReplacementNamed(context, '/settings');
//                 break;
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureCard(String title, IconData icon) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.all(8),
//       child: InkWell(
//         onTap: () {
//           // Handle feature tap
//             if (title == 'SAR Image Colorization') {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SARColorizationScreen()),
//         );
//       }  if(title == 'Flood Area Detection'){
//         Navigator.push(
// context,
// MaterialPageRoute(builder: (context)=> const FloodAreaDetectionScreen()),

//         );
//       }
//        if(title == 'Crop Mapping'){
//         Navigator.push(
// context,
// MaterialPageRoute(builder: (context)=> const CropMappingScreen()),

//         );
//       }
//        if(title == 'Historical Analysis'){
//         Navigator.push(
// context,
// MaterialPageRoute(builder: (context)=> const HistoricalAnalysisScreen()),

//         );
//       }
//        if(title == 'AI Insights'){
//         Navigator.push(
// context,
// MaterialPageRoute(builder: (context)=> const AIInsightsScreen()),

//         );
//       }
//         },
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: Colors.blue, size: 40),
//             const SizedBox(height: 8),
//             Text(title, style: const TextStyle(fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildClassifySection() {
//   return Card(
//     child: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const Text('Classify Crop Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 16),
//           if (_image == null)
//             Container(
//               height: 300,
//               width: 200,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/images/14.jpeg'), 
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           if (_image != null)
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: FileImage(_image!),
//                   fit: BoxFit.cover,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.upload),
//             label: Text(_isClassifying ? 'Classifying...' : 'Tap to classify image'),
//             onPressed: _isClassifying ? null : _pickImage,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//           ),
//           if (_classificationResult != null) ...[
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Classification Result:',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(_classificationResult!),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _clearClassification,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: Text('Clear'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     ),
//   );
// }

  
// }
// class FloodAreaDetectionCard extends StatelessWidget {
//   final VoidCallback onTap;

//   const FloodAreaDetectionCard({required this.onTap, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text('Flood Area Detection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/images/12.jpeg'), 
//                   fit: BoxFit.cover,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.water_damage),
//               label: const Text('Detect Flood Area'),
//               onPressed: onTap,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  File? _image;
  bool _isClassifying = false;
  String? _classificationResult;

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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _classifyImage();
      } else {
        print('No image selected.');
      }
    });
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
          _classificationResult = 'Failed to classify image. Status code: ${response.statusCode}';
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

  void _showChatbot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('AI Chatbot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: const AIInsightsScreen(),
              ),
            ],
          ),
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
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(' SARVISION', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          automaticallyImplyLeading: false,
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
                FloodAreaDetectionCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FloodAreaDetectionScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SARImageColorizationCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SARColorizationScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // _buildClassifySection(),
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
              MaterialPageRoute(builder: (context) => const FloodAreaDetectionScreen()),
            );
          }
          if (title == 'Crop Mapping') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CropMappingScreen()),
            );
          }
          if (title == 'Historical Analysis') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoricalAnalysisScreen()),
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
            const Text('Classify Crop Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_image == null)
              Container(
                height: 300,
                width: 200,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/14.jpeg'),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            if (_image != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: Text(_isClassifying ? 'Classifying...' : 'Tap to classify image'),
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
}

class FloodAreaDetectionCard extends StatelessWidget {
  final VoidCallback onTap;

  const FloodAreaDetectionCard({required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Flood Area Detection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/12.jpeg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.water_damage),
              label: const Text('Detect Flood Area'),
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SARImageColorizationCard extends StatelessWidget {
  final VoidCallback onTap;

  const SARImageColorizationCard({required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('SAR Image Colorization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/15.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.color_lens),
              label: const Text('Colorize SAR Image'),
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}