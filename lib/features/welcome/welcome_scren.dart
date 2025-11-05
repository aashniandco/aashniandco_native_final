import 'package:aashniandco/features/auth/view/auth_screen.dart';
import 'package:aashniandco/features/login/view/login_screen.dart';
import 'package:aashniandco/features/signup/view/signup_screen.dart';
import 'package:aashniandco/features/welcome/webview_login_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Color primaryDark = Colors.black;
final Color buttonDark = Colors.grey[850]!;
final Color buttonMedium = Colors.grey[800]!;
final Color buttonLight = Colors.grey[700]!;
final Color textGrey = Colors.grey[400]!;



class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isCheckingLogin = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('user_token');

    if (userToken != null && userToken.isNotEmpty) {
      // ✅ User is logged in → navigate directly to AuthScreen (or ProfileScreen)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen()),
            (route) => false,
      );
    } else {
      // ❌ User not logged in → show welcome screen
      setState(() {
        _isCheckingLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLogin) {
      // While checking login, show a loading indicator
      return Scaffold(
        backgroundColor: primaryDark,
        body: Center(
          child: CircularProgressIndicator(color: textGrey),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose an option to continue',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Log In
              _buildElevatedButton(
                context,
                text: 'Log In',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen1()),
                  );

                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const WebViewLoginScreen()),
                  // );
                },
                gradientColors: [buttonDark, buttonMedium],
              ),
              const SizedBox(height: 20),

              // Sign Up
              _buildElevatedButton(
                context,
                text: 'Sign Up',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SignupScreen()),
                  );
                },
                gradientColors: [buttonMedium, buttonLight],
              ),
              const SizedBox(height: 20),

              // Continue as Guest
              _buildElevatedButton(
                context,
                text: 'Continue as Guest',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => AuthScreen()),
                  );
                },
                gradientColors: [buttonLight, Colors.grey[600]!],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButton(
      BuildContext context, {
        required String text,
        required VoidCallback onPressed,
        required List<Color> gradientColors,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

