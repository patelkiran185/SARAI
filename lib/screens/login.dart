import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
  bool _isGooglePressed = false;
  bool _isGithubPressed = false;
  bool _isLoading = false;

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

  void _showDialog(BuildContext context, String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFA49E9E), // Set background color
          title: Text(title, style: const TextStyle(color: Colors.white)), // Set title text color
          content: Text(message, style: const TextStyle(color: Colors.white)), // Set content text color
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (isSuccess) {
                  Navigator.pushReplacementNamed(context, '/home'); // Redirect on success
                }
              },
              child: const Text("OK", style: TextStyle(color: Colors.white)), // Set button text color
            ),
          ],
        );
      },
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true); // Save login state
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      }

      _showDialog(context, 'Error', errorMessage, false);
    } catch (e) {
      _showDialog(context, 'Error', 'An unexpected error occurred.', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAnimatedIcon(
      String assetPath, VoidCallback onPressed, bool isPressed,
      {double iconSize = 20}) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: Image.asset(
            assetPath,
            color: isPressed ? Colors.purple : Colors.white,
          ),
          iconSize: iconSize,
          onPressed: onPressed,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField(
      TextEditingController controller, String label, IconData icon) {
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
                cursorColor: Colors.purple,
                cursorHeight: 25,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: Icon(icon, color: Colors.white, size: 18),
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
    return Scaffold(
      backgroundColor: const Color(0xFFA49E9E),
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
                      _passwordController, 'Password', Icons.lock),
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
                  Row(
                    children: const [
                      Expanded(
                          child: Divider(color: Colors.white, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text("OR",
                            style: TextStyle(color: Colors.white)),
                      ),
                      Expanded(
                          child: Divider(color: Colors.white, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedIcon('assets/images/google_icon.png', () {
                        // Google login implementation here
                      }, _isGooglePressed),
                      const SizedBox(width: 20),
                      _buildAnimatedIcon('assets/images/github_icon.png', () {
                        // GitHub login implementation here
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
    );
  }
}
