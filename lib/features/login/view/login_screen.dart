import 'package:aashniandco/features/login/view/forgot_password.dart';
import 'package:aashniandco/features/signup/view/signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/view/auth_screen.dart';
import '../repository/login_repository.dart';
import '../model/login_model.dart';

class LoginScreen1 extends StatefulWidget {
  const LoginScreen1({super.key});

  @override
  State<LoginScreen1> createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool isLoggedIn = false;

  final LoginRepository _loginRepository =
  // LoginRepository(baseUrl: 'https://aashniandco.com');
  LoginRepository(baseUrl: 'https://aashniandco.com');
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> userLoggedInSuccessfully() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserLoggedIn', true);
    if (mounted) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  // In lib/features/login/view/login_screen.dart

  Future<void> _submitForm() async {
    // --- No changes here ---
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    final request = MagentoLoginRequest(
      username: _email.text.trim(),
      password: _password.text.trim(),
    );

    String? loginError;
    bool loginSuccess = false;

    try {
      // --- Perform the async work ---
      await _loginRepository.login(request);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      if (token != null && token.isNotEmpty) {
        // If we get here, the async part was successful.
        loginSuccess = true;
        await prefs.setString('user_email', _email.text.trim());
        await prefs.setString('user_password', _password.text.trim());
      } else {
        loginError = 'Failed to retrieve token after login.';
      }
    } catch (e) {
      // Capture the specific error message
      loginError = e.toString();
    }

    // --- After all async work is done, now we handle the UI ---
    // ✅ CRITICAL FIX: Check if the widget is still mounted before using its context.
    if (!mounted) return;

    setState(() => _loading = false);

    if (loginSuccess) {
      // All UI updates happen here, inside the mounted check.
      userLoggedInSuccessfully(); // This is just a setState call, it's fine.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AuthScreen()),
            (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${loginError ?? "An unknown error occurred."}')),
      );
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black87),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return '$label is required';
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Enter a valid email';
          }
          if (label == "Password" && value.length < 6) {
            return "Password must be at least 6 characters";
          }
          return null;
        },
      ),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
    );
  }

  void _navigateToCreateAccount() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),

          // --- THIS IS THE CHANGED LINE ---
          onPressed: () {
            // Navigate to AuthScreen and clear the navigation stack
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (Route<dynamic> route) => false, // This predicate removes all routes
            );
          },
          // --- END OF CHANGE ---

        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      // --- END OF ADDITION ---

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top:10,left: 24,right: 24,bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/logo.jpeg',
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      _buildField(label: "Email", controller: _email, isEmail: true),
                      _buildField(label: "Password", controller: _password, obscureText: true),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _navigateToForgotPassword,
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _loading ? null : _submitForm,
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Login",
                              style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: _navigateToCreateAccount,
                            child: const Text("Create Account",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isNetworkError(String message) {
    return message.contains("SocketException") ||
        message.contains("ClientException") ||
        message.contains("Failed host lookup");
  }

}