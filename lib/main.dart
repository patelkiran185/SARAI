import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart'; 
import 'screens/login.dart'; 
import 'screens/register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SARAI',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(), 
        '/onboarding': (context) => OnboardingScreen(), 
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
  }

  _checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? seen = prefs.getBool('isFirstLaunch');

   
    if (seen == null || seen == true) {
      await prefs.setBool('isFirstLaunch', false);
      Navigator.of(context).pushReplacementNamed('/onboarding'); 
    } else {
      Navigator.of(context).pushReplacementNamed('/login'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // Simple loading indicator
    );
  }
}
