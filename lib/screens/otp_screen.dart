
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final String userId;

  OtpScreen({required this.email, required this.phoneNumber, required this.userId});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _verifyEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if the user has verified their email
      User? user = _auth.currentUser;
      await user?.reload();
      user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        // Update user verification status in Firestore
        await _firestore.collection('users').doc(widget.userId).update({
          'isVerified': true,
        });

        _showDialog('Verification Successful', 'Your email has been verified. You can now use the app.', true);
      } else {
        _showDialog('Verification Error', 'Please verify your email before proceeding.', false);
      }
    } catch (e) {
      _showDialog('Verification Error', 'An error occurred during verification: ${e.toString()}', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        _showDialog('Email Sent', 'A new verification email has been sent to your email address.', true);
      }
    } catch (e) {
      _showDialog('Error', 'Failed to resend verification email: ${e.toString()}', false);
    }
  }

  void _showDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Email')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please check your email and verify your account.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyEmail,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('I have verified my email'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _resendVerificationEmail,
              child: Text('Resend verification email'),
            ),
          ],
        ),
      ),
    );
  }
}