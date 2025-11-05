import 'package:aashniandco/features/welcome/welcome_scren.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to WelcomeScreen after 3 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo
            Image.asset(
              'assets/splash_new.png', // Add your logo in assets
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 100),

            const SizedBox(height: 10),
            CircularProgressIndicator(
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
