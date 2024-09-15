
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sarai/services/auth_service.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isGooglePressed = false;
  bool _isGithubPressed = false;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // normal email/ password

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showDialog(context, 'Login Error', 'Please fill all fields.', false);
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user exists in Firebase Authentication
      User? user = userCredential.user;

      if (user != null) {
        // User exists, navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showDialog(
            context, 'Login Error', 'User not found in Firebase.', false);
      }
    } catch (e) {
      _showDialog(context, 'Login Error', e.toString(), false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(
      BuildContext context, String title, String message, bool isSuccess) {
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

  Widget _buildAnimatedIcon(
      String assetPath, VoidCallback onPressed, bool isPressed) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedScale(
        scale: isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: IconButton(
          onPressed: onPressed,
          icon: Image.asset(assetPath),
          iconSize: 40,
        ),
      ),
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
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/login.png',
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedTextField(
                        _emailController, 'Email', Icons.email),
                    const SizedBox(height: 15),
                    _buildAnimatedTextField(
                        _passwordController, 'Password', Icons.lock,
                        isPassword: true),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTapDown: (_) => _animationController.forward(),
                      onTapUp: (_) => _animationController.reverse(),
                      onTapCancel: () => _animationController.reverse(),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: ElevatedButton(
                          onPressed: _signIn,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Login',
                                  style: TextStyle(color: Colors.grey)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 247, 244, 248),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
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
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedIcon('assets/images/google_icon.png',
                            () async {
                          final authService = AuthService();
                          await authService.loginWithGoogle(context);
                        }, _isGooglePressed),
                        const SizedBox(width: 20),
                        _buildAnimatedIcon('assets/images/github_icon.png',
                            () async {
                          final authService = AuthService();
                          final result =
                              await authService.loginWithGitHub(context);
                          if (result != null) {
                            // User successfully authenticated with GitHub
                            Navigator.pushReplacementNamed(context, '/home');
                          } else {
                            // Handle authentication failure
                            _showDialog(context, 'Login Error',
                                'Failed to authenticate with GitHub', false);
                          }
                        }, _isGithubPressed),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Don\'t have an account? Register here.',
                        style: TextStyle(color: Colors.white),
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
