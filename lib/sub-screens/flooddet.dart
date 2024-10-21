import 'package:flutter/material.dart';

class FloodAreaDetectionScreen extends StatelessWidget {
  const FloodAreaDetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Flood Area Detection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMapView(),
            SizedBox(height: 16),
            _buildDetectionControls(),
            SizedBox(height: 16),
            Text(
              'Recent Detections',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _buildRecentDetectionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Map View',
          style: TextStyle(fontSize: 18, color: Colors.blue[800]),
        ),
      ),
    );
  }

  Widget _buildDetectionControls() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {},
          child: Text('New Detection'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
          ),
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildRecentDetectionsList() {
    return ListView(
      children: [
        _buildDetectionItem('Flood Alert #1', 'High', '2 hours ago'),
        _buildDetectionItem('Flood Alert #2', 'High', '2 hours ago'),
        _buildDetectionItem('Flood Alert #3', 'High', '2 hours ago'),
      ],
    );
  }

  Widget _buildDetectionItem(String title, String severity, String timeAgo) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.warning, color: Colors.red),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Severity: $severity'),
            Text('Detected: $timeAgo'),
          ],
        ),
      ),
    );
  }
}