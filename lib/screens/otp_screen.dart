import 'dart:async';
import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final User user;

  const OtpScreen({super.key, required this.user});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _emailOtp = EmailOTP();
  int _resendTimer = 60;
  late Timer _timer;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _setUpEmailOtp();
    _startResendTimer();
  }

  void _setUpEmailOtp() {
    _emailOtp.setConfig(
      appEmail: 'makethon0@gmail.com',
      appName: 'sarai',
      userEmail: widget.user.email!,
    );
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      _errorMessage = '';
    });
    bool otpSent = await _emailOtp.sendOTP();
    if (otpSent) {
      print("OTP sent successfully");
      setState(() {
        _resendTimer = 60;
      });
      _startResendTimer();
    } else {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text;
    print("Verifying OTP: $otp");

    bool isOtpValid = await _emailOtp.verifyOTP(otp: otp);

    if (isOtpValid) {
      print("OTP is valid ✅");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      print("OTP is invalid ❌");
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
      await _sendOtp();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify OTP', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.email, size: 80, color: Colors.blue),
              const SizedBox(height: 40),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'A verification code has been sent to ${widget.user.email}. Please enter the OTP below to verify your account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 150, // Set the width to 100
                  child: ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(50), // Make the button round
                      ),
                    ),
                    child: Text(
                      'Verify OTP',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white), // Set text color to white
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _resendTimer == 0 ? _sendOtp : null,
                child: Text(
                  _resendTimer > 0
                      ? 'Resend OTP in $_resendTimer seconds'
                      : 'Resend OTP',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
