import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:gallery_saver/gallery_saver.dart';

import '../utils/bottomNavigation.dart';

class SARColorizationScreen extends StatefulWidget {
  @override
  _SARColorizationScreenState createState() => _SARColorizationScreenState();
}

class _SARColorizationScreenState extends State<SARColorizationScreen> {
  File? _selectedImage;
  String? _colorizedImageUrl;
  bool _isLoading = false;
  int _currentIndex = 0;

  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _colorizedImageUrl = null; // Clear any previous output
      });
    }
  }

  // Function to upload the image and get the colorized image
  Future<void> _colorizeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image first!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('http://192.168.70.197:5000/colorize'); // Update with your API URL
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.toBytes();
        final base64Image = base64Encode(responseBody);

        setState(() {
          _colorizedImageUrl = "data:image/png;base64,$base64Image";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to colorize image: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to download the colorized image
  Future<void> _downloadImage() async {
    if (_colorizedImageUrl != null) {
      final bytes = base64Decode(_colorizedImageUrl!.split(',')[1]);
      final tempDir = await Directory.systemTemp.createTemp();
      final file = await File('${tempDir.path}/colorized_image.png').writeAsBytes(bytes);

      final result = await GallerySaver.saveImage(file.path);
      if (result != null && result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery')),
        );
      }
    }
  }

  Widget _imageContainer({required Widget child}) {
    return Container(
      height: 150, // Consistent size for both images
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }

  void _onItemSelected(int index) {
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
        Navigator.pushReplacementNamed(context, '/aiins');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Colorisation of SAR imagery',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display the selected image
            if (_selectedImage != null)
              _imageContainer(
                child: Image.file(
                  _selectedImage!,
                ),
              )
            else
              _imageContainer(
                child: Center(
                  child: Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
            SizedBox(height: 16),
            // Button to pick an image
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
              ),
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text('Select Image'),
            ),
            SizedBox(height: 16),
            // Button to colorize the image
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
              ),
              onPressed: _colorizeImage,
              icon: Icon(Icons.colorize),
              label: Text('Colorize'),
            ),
            SizedBox(height: 16),
            // Display a loading spinner while processing
            if (_isLoading) Center(child: CircularProgressIndicator()),
            // Display the colorized image
            if (_colorizedImageUrl != null)
              Column(
                children: [
                  Text(
                    'Colorized Image:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _imageContainer(
                    child: Image.memory(
                      base64Decode(_colorizedImageUrl!.split(',')[1]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    ),
                    onPressed: _downloadImage,
                    icon: Icon(Icons.download),
                    label: Text('Download Image'),
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}