import 'package:flutter/material.dart';

class HistoricalAnalysisScreen extends StatefulWidget {
  const HistoricalAnalysisScreen({Key? key}) : super(key: key);

  @override
  _HistoricalAnalysisScreenState createState() =>
      _HistoricalAnalysisScreenState();
}

class _HistoricalAnalysisScreenState extends State<HistoricalAnalysisScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedTrend = 'Floods';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Historical Analysis'),
      ),
      body: SingleChildScrollView(
        // Wrap the content in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrendAnalysis(),
            SizedBox(height: 16),
            _buildSignificantEvents(),
            SizedBox(height: 16),
            _buildComparePeriods(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trend Analysis',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(child: Text('Graph Placeholder')),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTrendButton('Floods'),
                  _buildTrendButton('Crop Yield'),
                  _buildTrendButton('Land Use'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendButton(String trend) {
    return ElevatedButton(
      onPressed: () => setState(() => selectedTrend = trend),
      child: Text(trend),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedTrend == trend ? Colors.black : Colors.grey,
      ),
    );
  }

  Widget _buildSignificantEvents() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Significant Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildEventItem('Major Flood', 'May 15, 2023'),
            _buildEventItem('Record Crop Yield', 'August 30, 2023'),
            _buildEventItem('Drought Period', 'July 1-20, 2023'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(String event, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(event),
          Text(date, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildComparePeriods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compare Periods',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'dd/mm/yyyy',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.compare_arrows),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'dd/mm/yyyy',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Generate Comparison'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
