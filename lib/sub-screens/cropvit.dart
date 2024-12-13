import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/bottomNavigation.dart'; // Import BottomNavigation

class CropUsingVitPage extends StatefulWidget {
  const CropUsingVitPage({super.key});

  @override
  _CropUsingVitPageState createState() => _CropUsingVitPageState();
}

class _CropUsingVitPageState extends State<CropUsingVitPage> {
  File? _image;
  String? _prediction;
  String? _errorMessage;
  int _currentIndex = 0;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          _errorMessage = null; // Clear any previous error message
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      print('No image to upload');
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['BACKEND_URL']}/classifyVit'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);
        var resBody = json.decode(responseBody.body);
        setState(() {
          _prediction = resBody['predicted_class_name'];
          _errorMessage = null; // Clear any previous error message
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to get prediction. Status code: ${response.statusCode}';
        });
        print('Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Server error: $e';
      });
      print('Error uploading image: $e');
    }
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
        Navigator.pushReplacementNamed(context, '/alerts');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crop Classification using ViT',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null)
              Image.file(
                _image!,
                height: 300,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 300,
                color: Colors.grey[200],
                child: const Center(
                  child: Text('No image selected'),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Select Image'),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Upload Image'),
              onPressed: _uploadImage,
            ),
            const SizedBox(height: 16),
            if (_prediction != null)
              Text(
                'Prediction: $_prediction',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            if (_errorMessage != null)
              Text(
                'Error: $_errorMessage',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
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