import 'package:flutter/material.dart';

class CropMappingScreen extends StatefulWidget {
  const CropMappingScreen({super.key});

  @override
  _CropMappingScreenState createState() => _CropMappingScreenState();
}

class _CropMappingScreenState extends State<CropMappingScreen> {
  String selectedMonth = 'May';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Crop Mapping'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 16),
              _buildFieldInfo(),
              const SizedBox(height: 16),
              _buildTimeline(),
              const SizedBox(height: 16),
              _buildFieldAnalysis(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 150,
            color: Colors.grey[300],
            child: const Center(child: Text('SAR Image')),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 150,
            color: Colors.green[100],
            child: const Center(child: Text('Ground Image')),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Field: Wheat-001', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Crop Health:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < 3 ? Icons.eco : Icons.eco_outlined,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {},
            ),
            _buildMonthButton('May'),
            _buildMonthButton('Jun'),
            _buildMonthButton('Jul'),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthButton(String month) {
    return ElevatedButton(
      onPressed: () => setState(() => selectedMonth = month),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedMonth == month ? Colors.black : Colors.grey,
      ),
      child: Text(month),
    );
  }

  Widget _buildFieldAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Field Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildAnalysisItem('Soil Moisture', 0.7),
        const SizedBox(height: 8),
        _buildAnalysisItem('Crop Yield Estimate', 0.9),
        const SizedBox(height: 8),
        _buildAnalysisItem('Pest Risk', 0.2),
      ],
    );
  }

  Widget _buildAnalysisItem(String title, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }
}