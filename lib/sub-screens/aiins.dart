import 'package:flutter/material.dart';

class AIInsightsScreen extends StatelessWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('AI Insights'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInsightsCard(),
              const SizedBox(height: 16),
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
            const Row(
              children: [
                Icon(Icons.bolt, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Latest AI-Generated Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Our AI has analyzed recent SAR data and generated the following insights:'),
            const SizedBox(height: 16),
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            const Text(
              'Recommended Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
          const Icon(Icons.arrow_right, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(action)),
        ],
      ),
    );
  }
}