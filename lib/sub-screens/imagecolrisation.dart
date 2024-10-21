import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';

class SARColorizationScreen extends StatefulWidget {
  @override
  _SARColorizationScreenState createState() => _SARColorizationScreenState();
}

class _SARColorizationScreenState extends State<SARColorizationScreen> {
  File? _image;
  File? _colorizedImage;
  bool _isLoading = false;

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _colorizedImage = null;
        _isLoading = true;
      });

      // Simulating colorization process
      await Future.delayed(Duration(seconds: 3));
      
      // In a real app, you would send the image to your GenAI model here
      // and receive the colorized image back

      setState(() {
        _colorizedImage = _image; // For demonstration, we're just using the same image
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadImage() async {
    if (_colorizedImage != null) {
      final result = await GallerySaver.saveImage(_colorizedImage!.path);
      if (result != null && result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to gallery')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SAR Image Colorization'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload SAR Image'),
              ),
              SizedBox(height: 16),
              if (_image != null) ...[
                Text('Original Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Image.file(_image!),
                SizedBox(height: 16),
              ],
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else if (_colorizedImage != null) ...[
                Text('Colorized Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Image.file(_colorizedImage!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _downloadImage,
                  child: Text('Download Colorized Image'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}