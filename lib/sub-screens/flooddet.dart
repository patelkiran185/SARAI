import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FloodAreaDetectionScreen extends StatefulWidget {
  const FloodAreaDetectionScreen({super.key});
  @override
  State<FloodAreaDetectionScreen> createState() =>
      _FloodAreaDetectionScreenState();
}

class _FloodAreaDetectionScreenState extends State<FloodAreaDetectionScreen> {
  Uint8List? _selectedImageBytes;
  Uint8List? _groundTruthBytes;
  Uint8List? _predictedMaskBytes;
  Uint8List? _resultImageBytes;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _groundTruthBytes = null;
        _predictedMaskBytes = null;
        _resultImageBytes = null;
      });
    }
  }

  Future<void> _detectFlood() async {
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload an image first.")),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${dotenv.env['BACKEND_URL']}/detect"),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _selectedImageBytes!,
        filename: 'image.jpg',
      ));
      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          _groundTruthBytes = base64Decode(jsonResponse['ground_truth']);
          _predictedMaskBytes = base64Decode(jsonResponse['predicted_mask']);
          _resultImageBytes = base64Decode(jsonResponse['result_image']);
        });
      } else {
        throw Exception("Error from server: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImageBytes = null; // Clear uploaded image
      _groundTruthBytes = null; // Clear ground truth mask
      _predictedMaskBytes = null; // Clear predicted mask
      _resultImageBytes = null; // Clear result image
      // Clear any result text
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flood Area Detection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and Instructions
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 20),
              ),
              const Text(
                "Upload an image to detect flood risks.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Buttons
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                  ),
                  child: const Text("Upload Image"),
                ),
              ),
              const SizedBox(height: 10),
              if (_selectedImageBytes != null)
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _clearImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                    ),
                    child: const Text("Clear Image"),
                  ),
                ),
              const SizedBox(height: 16),

              // Show Uploaded Image
              if (_selectedImageBytes != null) ...[
                const Text(
                  "Uploaded Image",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.memory(
                      _selectedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Detect Button
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _detectFlood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                  ),
                  child: const Text("Detect Flood"),
                ),
              ),
              const SizedBox(height: 16),

              if (_isLoading) const Center(child: CircularProgressIndicator()),

              // Show Processed Image and Result
              if (!_isLoading &&
                  (_selectedImageBytes != null ||
                      _groundTruthBytes != null ||
                      _predictedMaskBytes != null ||
                      _resultImageBytes != null))
                Column(
                  children: [
                    if (_groundTruthBytes != null) ...[
                      const Text("Ground Truth Image",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Image.memory(_groundTruthBytes!,
                              fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_predictedMaskBytes != null) ...[
                      const Text("Predicted Image",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Image.memory(_predictedMaskBytes!,
                              fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_resultImageBytes != null) ...[
                      const Text("Flood Detected Image",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Image.memory(_resultImageBytes!,
                              fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
