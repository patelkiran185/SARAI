import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:sarai/screens/home_screen.dart';
import 'package:sarai/screens/login.dart';
import 'package:sarai/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedUserType;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phoneNumber.isEmpty ||
        _selectedUserType == null) {
      _showDialog('Registration Error',
          'Please fill all fields and select a user type.', false);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validate phone number
    if (phoneNumber.length != 10 ||
        !RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber)) {
      _showDialog('Registration Error',
          'Invalid phone number. It should be exactly 10 digits.', false);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validate email
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showDialog('Registration Error', 'Invalid email format.', false);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validate password
    if (password.length < 6 ||
        !RegExp(r'^(?=.*[A-Z])(?=.*[!@#$&*]).{6,}$').hasMatch(password)) {
      _showDialog(
          'Registration Error',
          'Password must be at least 6 characters long, contain at least one capital letter, and one special character.',
          false);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // Store user data in Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'userType': _selectedUserType,
        'isVerified': false,
      }).then((_) {
        print("User data added to Firestore successfully.");
      }).catchError((error) {
        print("Failed to add user data to Firestore: $error");
      });

      // Navigate to Home screen
      final authService = AuthService();
      await authService.setLoggedIn(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } catch (e) {
      _showDialog('Registration Error',
          'An error occurred during registration: ${e.toString()}', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
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
                obscureText: isPassword && !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: Icon(icon, color: Colors.white, size: 18),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF4A90E2),
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
                    _buildAnimatedTextField(
                        _nameController, 'Name', Icons.person),
                    const SizedBox(height: 15),
                    _buildAnimatedTextField(
                        _emailController, 'Email', Icons.email),
                    const SizedBox(height: 15),
                    _buildAnimatedTextField(
                        _passwordController, 'Password', Icons.lock,
                        isPassword: true),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedUserType,
                        hint: const Text('Select User Type',
                            style: TextStyle(color: Colors.white54)),
                        items: const [
                          DropdownMenuItem(
                              value: 'Researcher', child: Text('Researcher')),
                          DropdownMenuItem(
                              value: 'Government', child: Text('Government')),
                          DropdownMenuItem(
                              value: 'Farmer', child: Text('Farmer')),
                          DropdownMenuItem(
                              value: 'Analyst', child: Text('Analyst')),
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
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 53, 132, 197),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildAnimatedTextField(
                        _phoneController, 'Phone Number', Icons.phone),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTapDown: (_) => _animationController.forward(),
                      onTapUp: (_) => _animationController.reverse(),
                      onTapCancel: () => _animationController.reverse(),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 247, 245, 245),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Register',
                                  style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(
                            child: Divider(color: Colors.white, thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child:
                              Text("OR", style: TextStyle(color: Colors.white)),
                        ),
                        Expanded(
                            child: Divider(color: Colors.white, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final authService = AuthService();
                            await authService.registerWithGoogle(context);
                            // No need to handle navigation here; AuthService will handle it
                          },
                          icon: Image.asset('assets/images/google_icon.png'),
                          iconSize: 20,
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () async {
                            final authService = AuthService();
                            final result =
                                await authService.registerWithGitHub(context);
                            if (result != null) {
                              // User successfully authenticated with GitHub
                              // You can save additional user info to Firestore here if needed
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HomeScreen(), // Ensure you have a LoginPage widget or route
                                ),
                              );
                            } else {
                              // Handle authentication failure
                              _showDialog('Registration Error',
                                  'Failed to authenticate with GitHub', false);
                            }
                          },
                          icon: Image.asset('assets/images/github_icon.png'),
                          iconSize: 20,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Already have an account? Login here",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

