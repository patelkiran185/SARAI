import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sarai/services/auth_service.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
  _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  ModalRoute.of(context)?.addScopedWillPopCallback(_onWillPop);
}

@override
void dispose() {
  _animationController.dispose();
  _emailController.dispose();
  _passwordController.dispose();
  ModalRoute.of(context)?.removeScopedWillPopCallback(_onWillPop);
  super.dispose();
}

Future<bool> _onWillPop() async {
  return false; // Prevent back navigation
}

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

      User? user = userCredential.user;

      if (user != null) {
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
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWebTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      width: double.infinity,
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(color: Colors.white), // Change text color to white
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)), // Make hint text white with opacity
          prefixIcon: Icon(icon, color: Colors.white, size: 20), // Make icon white
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white, // Make visibility icon white
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1), // Semi-transparent white background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)), // White border with opacity
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white), // Solid white border when focused
          ),
        ),
      ),
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

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
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
            _buildAnimatedTextField(_emailController, 'Email', Icons.email),
            const SizedBox(height: 15),
            _buildAnimatedTextField(_passwordController, 'Password', Icons.lock,
                isPassword: true),
            const SizedBox(height: 20),
            _buildLoginButton(isMobile: true),
            const SizedBox(height: 20),
            _buildDivider(isMobile: true),
            const SizedBox(height: 15),
            _buildSocialLogin(),
            const SizedBox(height: 20),
            _buildRegisterLink(isMobile: true),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Center(
      child: Container(
        width: 600,  // Increased width
        height: 700,
        margin: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.2),  // Match the blur color with lower opacity
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 225, 229, 236).withOpacity(0.6),  // Neon effect color
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.6),
              spreadRadius: 5,
              blurRadius: 20,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/login.png',
                  height: 120,
                ),
                const SizedBox(height: 32),
                _buildWebTextField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 16),
                _buildWebTextField(
                  _passwordController,
                  'Password',
                  Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                _buildLoginButton(isMobile: false),
                const SizedBox(height: 24),
                _buildDivider(isMobile: false),
                const SizedBox(height: 24),
                _buildSocialLogin(),
                const SizedBox(height: 24),
                _buildRegisterLink(isMobile: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({required bool isMobile}) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider({required bool isMobile}) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isMobile ? Colors.white : Colors.grey[300],
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OR",
            style: TextStyle(
              color: isMobile ? Colors.white : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isMobile ? Colors.white : Colors.grey[300],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          'assets/images/google_icon.png',
          () async {
            final authService = AuthService();
            await authService.loginWithGoogle(context);
          },
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          'assets/images/github_icon.png',
          () async {
            final authService = AuthService();
            final result = await authService.loginWithGitHub(context);
            if (result != null) {
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              _showDialog(context, 'Login Error',
                  'Failed to authenticate with GitHub', false);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton(String assetPath, VoidCallback onPressed) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Image.asset(assetPath),
        iconSize: 24,
      ),
    );
  }

  Widget _buildRegisterLink({required bool isMobile}) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/register');
      },
      child: Text(
        'Don\'t have an account? Register here',
        style: TextStyle(
           color: kIsWeb ? Colors.white : (isMobile ? Colors.white : Colors.grey[600]),
          fontSize: 14,
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A90E2),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (kIsWeb || constraints.maxWidth > 800) {
              return _buildWebLayout();
            }
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }
}