import 'package:aashniandco/features/welcome/welcome_scren.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../../update_app/update_service.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Navigate to WelcomeScreen after 3 seconds
//     Timer(Duration(seconds: 10), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => WelcomeScreen()),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Your app logo
//             Image.asset(
//               'assets/splash_new.png', // Add your logo in assets
//               width: 500,
//               height: 500,
//             ),
//             const SizedBox(height: 100),
//
//             const SizedBox(height: 10),
//             CircularProgressIndicator(
//               color: Colors.grey[400],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isForceUpdate = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 🔍 Check for update first
      _isForceUpdate = await AppUpdateService.checkForUpdate(context);

      // ⏳ Navigate only if NOT force update
      if (!_isForceUpdate) {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    Timer(const Duration(seconds: 10), () {
      if (!mounted) return;

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
            Image.asset(
              'assets/splash_new.png',
              width: 500,
              height: 500,
            ),
            const SizedBox(height: 100),
            CircularProgressIndicator(
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
