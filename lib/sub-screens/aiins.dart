// import 'package:flutter/material.dart';

// class AIInsightsScreen extends StatelessWidget {
//   const AIInsightsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('AI Insights'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildInsightsCard(),
//               const SizedBox(height: 16),
//               _buildRecommendedActionsCard(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInsightsCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Row(
//               children: [
//                 Icon(Icons.bolt, color: Colors.amber),
//                 SizedBox(width: 8),
//                 Text(
//                   'Latest AI-Generated Insights',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             const Text('Our AI has analyzed recent SAR data and generated the following insights:'),
//             const SizedBox(height: 16),
//             _buildInsightItem(
//               icon: Icons.trending_up,
//               title: 'Crop Yield Prediction',
//               description: '10% increase expected in wheat yield this season',
//             ),
//             _buildInsightItem(
//               icon: Icons.warning,
//               title: 'Flood Risk Alert',
//               description: 'Moderate risk of flooding in the next 48 hours',
//             ),
//             _buildInsightItem(
//               icon: Icons.water_drop,
//               title: 'Soil Moisture Analysis',
//               description: 'Optimal moisture levels detected in 80% of fields',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInsightItem({required IconData icon, required String title, required String description}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: Colors.blue),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//                 Text(description),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecommendedActionsCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Recommended Actions',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             _buildActionItem('Review flood prevention measures in high-risk areas'),
//             _buildActionItem('Optimize irrigation schedules based on soil moisture analysis'),
//             _buildActionItem('Prepare for increased crop yield by ensuring adequate storage'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionItem(String action) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.arrow_right, size: 20),
//           const SizedBox(width: 8),
//           Expanded(child: Text(action)),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/bottomNavigation.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({Key? key}) : super(key: key);

  @override
  _AIInsightsScreenState createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  Future<void> _getInsights(String question) async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = dotenv.env['API_KEY'];
    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": [
            {"parts": [{"text": question}]}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final answer = data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response';
        setState(() {
          _messages.add({"sender": "AI", "text": answer});
        });
      } else {
        setState(() {
          _messages.add({"sender": "AI", "text": "Failed to fetch insights. Please try again."});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"sender": "AI", "text": "Error occurred: $e"});
      });
    } finally {
      setState(() {
        _isLoading = false;
        _scrollToBottom();
      });
    }
  }

  void _sendMessage() {
    final question = _questionController.text.trim();
    if (question.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "User", "text": question});
      });
      _getInsights(question);
      _questionController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _onItemSelected(int index) {
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
    return Scaffold(
      appBar: AppBar(title: const Text("AI Insights")),
      body: Column(
        children: [
          // Chat History
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              reverse: false,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["sender"] == "User";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser
                            ? const Radius.circular(12)
                            : const Radius.circular(0),
                        bottomRight: isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      message["text"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input and Send Button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: "Type your message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2, // Set the current index to 2 for AI Insights
        onItemSelected: _onItemSelected,
      ),
    );
  }
}