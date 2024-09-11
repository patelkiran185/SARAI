import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedUserType;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    try {
      // Try to create a new user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      // Store user data in Firestore if registration is successful
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'userType': _selectedUserType,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Show success dialog
        _showDialog(context, "Success", "You have successfully registered!", true);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // If the email is already registered, log in the user instead
        print('The email address is already in use. Logging in...');
        try {
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          print('Successfully logged in');
          // Navigate to a different screen or show a success message
          Navigator.pushReplacementNamed(context, '/login'); // Redirect to home after login
        } catch (signInError) {
          print('Error during login: $signInError');
          _showDialog(context, "Error", "Error during login: $signInError", false);
        }
      } else if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        _showDialog(context, "Error", "The password provided is too weak.", false);
      } else {
        print('Error: ${e.message}');
        _showDialog(context, "Error", e.message ?? "An error occurred.", false);
      }
    } catch (e) {
      print('Error: $e');
      _showDialog(context, "Error", "An unexpected error occurred.", false);
    }
  }

  void _showDialog(BuildContext context, String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (isSuccess) {
                  Navigator.pushReplacementNamed(context, '/login'); // Redirect to login page if success
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(icon, color: Colors.white, size: 18),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA49E9E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Name Input Field
                  _buildAnimatedTextField(_nameController, 'Name', Icons.person),
                  const SizedBox(height: 15),

                  // Email Input Field
                  _buildAnimatedTextField(_emailController, 'Email', Icons.email),
                  const SizedBox(height: 15),

                  // Password Input Field
                  _buildAnimatedTextField(_passwordController, 'Password', Icons.lock),
                  const SizedBox(height: 15),

                  // User Type Dropdown
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedUserType,
                      hint: Text('Select User Type', style: TextStyle(color: Colors.white54)),
                      items: [
                        DropdownMenuItem(value: 'Researcher', child: Text('Researcher')),
                        DropdownMenuItem(value: 'Government', child: Text('Government')),
                        DropdownMenuItem(value: 'Farmer', child: Text('Farmer')),
                        DropdownMenuItem(value: 'Analyst', child: Text('Analyst')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedUserType = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      dropdownColor: Color(0xFFA49E9E),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Phone Number Input Field (Optional)
                  _buildAnimatedTextField(_phoneController, 'Phone Number (Optional)', Icons.phone),
                  const SizedBox(height: 20),

                  // Register Button
                  GestureDetector(
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) => _animationController.reverse(),
                    onTapCancel: () => _animationController.reverse(),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: ElevatedButton(
                        onPressed: _register, // Call the _register function here
                        child: const Text('Register', style: TextStyle(color: Colors.grey)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 247, 245, 245),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Social Sign-Up
                  Text('OR', style: TextStyle(color: const Color.fromARGB(255, 247, 246, 246))),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Google sign-up logic
                        },
                        icon: Image.asset('assets/images/google_icon.png'),
                        iconSize: 20, // Decreased icon size
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          // GitHub sign-up logic
                        },
                        icon: Image.asset('assets/images/github_icon.png'),
                        iconSize: 20, // Decreased icon size
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}