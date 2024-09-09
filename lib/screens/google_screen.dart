import 'package:flutter/material.dart';

class GoogleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Screen'),
      ),
      body: Center(
        child: Text('Welcome to Google Screen!'),
      ),
    );
  }
}