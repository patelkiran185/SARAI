import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sarai/screens/alerts.dart';
import 'package:sarai/screens/search.dart';
import 'package:sarai/screens/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  try {
    await dotenv.load(fileName: ".env");
    print("Loaded .env file successfully");
  } catch (e) {
    print("Failed to load .env file: $e");
    // You might want to set some default values here if needed
  }

  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    isLoggedIn = true;
    await prefs.setBool('isLoggedIn', true);
  }

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding, isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;

  const MyApp(
      {Key? key, required this.hasSeenOnboarding, required this.isLoggedIn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SARAI',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(
            hasSeenOnboarding: hasSeenOnboarding, isLoggedIn: isLoggedIn),
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => SettingsScreen(),
        '/alerts': (context) => AlertsScreen(),
        '/search':(context) => SearchScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;

  const SplashScreen({Key? key, required this.hasSeenOnboarding, required this.isLoggedIn}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3));

    if (!widget.hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (widget.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFB3D1F3)],
                stops: [0.3, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                strokeWidth: 6,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
