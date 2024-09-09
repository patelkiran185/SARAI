import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  String? _selectedUserType;
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
    super.dispose();
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
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, color: Colors.white, size: 20),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),

                  // Email Input Field
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.white, size: 20),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),

                  // Password Input Field
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.white, size: 20),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),

                  // User Type Dropdown
                  DropdownButtonFormField<String>(
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
                  const SizedBox(height: 15),

                  // Phone Number Input Field (Optional)
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number (Optional)',
                      prefixIcon: Icon(Icons.phone, color: Colors.white, size: 20),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Enter your phone number',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // Register Button
                  GestureDetector(
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) => _animationController.reverse(),
                    onTapCancel: () => _animationController.reverse(),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
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
                          // Kaggle sign-up logic
                        },
                        icon: Image.asset('assets/images/kaggle_icon.png'),
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