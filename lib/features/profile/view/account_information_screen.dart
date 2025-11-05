import 'package:aashniandco/features/login/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _changeEmail = false;
  bool _changePassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _firstNameController.text = prefs.getString('first_name') ?? "";
      _lastNameController.text = prefs.getString('last_name') ?? "";
      _emailController.text = prefs.getString('email') ?? "";
    });
  }

  Future<void> _updateAccountInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    print("tokenAC>>$token");// 🔑 must be stored after login

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final url =
    Uri.parse("https://stage.aashniandco.com/rest/V1/solr/updateAccountInfo");

    final body = {
      "currentPassword": _changePassword ? _currentPasswordController.text : "",
      "newPassword": _changePassword ? _newPasswordController.text : "",
      "newEmail": _changeEmail ? _emailController.text : "",
    };

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account information updated. Please log in again.")),
        );

        // 🔑 Immediately sign out and redirect to login/signup
        await _signOut(context);
      }
      else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${error['message']}")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('email');

    _navigateToLogin(context);
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen1()),
          (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Information"),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // First Name
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: "First Name *",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "First name is required" : null,
            ),
            const SizedBox(height: 16),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: "Last Name *",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Last name is required" : null,
            ),
            const SizedBox(height: 16),

            // Change Email
            CheckboxListTile(
              title: const Text("Change Email"),
              value: _changeEmail,
              onChanged: (value) {
                setState(() {
                  _changeEmail = value ?? false;
                });
              },
            ),

            // Change Password
            CheckboxListTile(
              title: const Text("Change Password"),
              value: _changePassword,
              onChanged: (value) {
                setState(() {
                  _changePassword = value ?? false;
                });
              },
            ),

            if (_changeEmail)
              Column(
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Email is required" : null,
                  ),
                ],
              ),

            if (_changePassword)
              Column(
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: "Current Password *",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                    value == null || value.isEmpty ? "Current password is required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: "New Password *",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                    value == null || value.isEmpty ? "New password is required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: "Confirm New Password *",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                    value != _newPasswordController.text ? "Passwords do not match" : null,
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Save button
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: _isLoading
                  ? null
                  : () async {
                if (_formKey.currentState!.validate()) {
                  await _updateAccountInfo();
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save"),
            ),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go back"),
            ),
          ],
        ),
      ),
    );
  }
}


