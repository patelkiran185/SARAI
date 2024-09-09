import 'package:flutter/material.dart';

class KaggleScreen extends StatelessWidget {
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