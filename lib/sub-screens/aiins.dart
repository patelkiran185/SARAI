import 'package:flutter/material.dart';

class AIInsightsScreen extends StatelessWidget {
  const AIInsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('AI Insights'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInsightsCard(),
              SizedBox(height: 16),
              _buildRecommendedActionsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Latest AI-Generated Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Our AI has analyzed recent SAR data and generated the following insights:'),
            SizedBox(height: 16),
            _buildInsightItem(
              icon: Icons.trending_up,
              title: 'Crop Yield Prediction',
              description: '10% increase expected in wheat yield this season',
            ),
            _buildInsightItem(
              icon: Icons.warning,
              title: 'Flood Risk Alert',
              description: 'Moderate risk of flooding in the next 48 hours',
            ),
            _buildInsightItem(
              icon: Icons.water_drop,
              title: 'Soil Moisture Analysis',
              description: 'Optimal moisture levels detected in 80% of fields',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildActionItem('Review flood prevention measures in high-risk areas'),
            _buildActionItem('Optimize irrigation schedules based on soil moisture analysis'),
            _buildActionItem('Prepare for increased crop yield by ensuring adequate storage'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, size: 20),
          SizedBox(width: 8),
          Expanded(child: Text(action)),
        ],
      ),
    );
  }
}