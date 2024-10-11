import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'home_screen.dart';

class PhoneScreen extends StatefulWidget {
  final User user;
  PhoneScreen({required this.user});

  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: '+91');
  final TextEditingController _otpController = TextEditingController();
late TwilioFlutter _twilioFlutter;
  String _generatedOtp = '';
  bool _otpSent = false;
  bool _isLoading = false; 

 @override
  void initState() {
    super.initState();
    _twilioFlutter = TwilioFlutter(
      accountSid: dotenv.env['TWILIO_ACCOUNT_SID']!,
      authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
      twilioNumber: dotenv.env['TWILIO_NUMBER']!,
    );
  }


  Future<void> _sendOtp() async {
    String phoneNumber = _phoneController.text.trim();
    String countryCode = _countryCodeController.text.trim();
    String? formattedPhoneNumber = _formatPhoneNumber(countryCode, phoneNumber);
    if (formattedPhoneNumber == null) {
      _showErrorDialog('Invalid phone number format. Please enter a valid phone number.');
      return;
    }
    _generatedOtp = _generateOtp();
    try {
      var response = await _twilioFlutter.sendSMS(
        toNumber: formattedPhoneNumber,
        messageBody: 'Your OTP code is: $_generatedOtp',
      );
      print("OTP Sent: $response");
      setState(() {
        _otpSent = true;
      });
    } catch (e) {
      print("Error sending OTP: $e");
      _showErrorDialog('Failed to send OTP. Please try again.');
    }
  }

  String _generateOtp() {
    return (100000 + (999999 - 100000) * (DateTime.now().millisecondsSinceEpoch % 1000000) / 1000000).toInt().toString();
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    String enteredOtp = _otpController.text.trim();
    if (enteredOtp == _generatedOtp) {
      
      await Future.delayed(Duration(seconds: 2));

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ));
    } else {
      _showErrorDialog('Invalid OTP. Please try again.');
    }

    setState(() {
      _isLoading = false; 
    });
  }

  String? _formatPhoneNumber(String countryCode, String phoneNumber) {
    final RegExp phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (phoneRegex.hasMatch(countryCode + phoneNumber)) {
      if (!countryCode.startsWith('+')) {
        countryCode = '+' + countryCode;
      }
      return countryCode + phoneNumber;
    }
    return null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Image.asset(
                  'assets/images/otp.png',
                  height: 180,
                  width: 180,
                ),
                SizedBox(height: 40),
                Text(
                  'Verify Phone',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        child: TextField(
                          controller: _countryCodeController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          keyboardType: TextInputType.phone,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          keyboardType: TextInputType.phone,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _sendOtp,
                  child: Text(
                    'Send OTP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                if (_otpSent) ...[
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Enter OTP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  _isLoading
                      ? Center(child: CircularProgressIndicator()) 
                      : ElevatedButton(
                          onPressed: _verifyOtp,
                          child: Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: _sendOtp,
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}