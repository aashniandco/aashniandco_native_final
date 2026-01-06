
import 'package:aashniandco/features/profile/view/account_information_screen.dart';
import 'package:aashniandco/features/profile/view/address_screen.dart';
import 'package:aashniandco/features/profile/view/store_credit_screen.dart';
import 'package:aashniandco/features/wishlist/view/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/api_constants.dart';
import '../../login/view/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../login/view/login_screen.dart';
import '../../signup/view/signup_screen.dart';
import 'order_history_screen.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _firstName;
  String? _lastName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('first_name') ?? "Guest";
      _lastName = prefs.getString('last_name') ?? "";
    });
  }

  Future<void> _signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await prefs.remove('first_name');
    await prefs.remove('last_name');

    _navigateToSignup(context);
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => SignupScreen()),
          (route) => false,
    );
  }

  /// 🔥 Call Magento delete account API
  Future<void> _deleteAccount(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are not logged in.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/V1/solr/deleteCustomer"), // ✅ Adjust API endpoint
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result == true) {
          // ✅ Successfully deleted
          await _signOut(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account deleted successfully.")),
          );
        } else {
          throw Exception("Delete failed");
        }
      } else {
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete account: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'customercare@aashniandco.com',
    );

    if (!await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch email';
    }
  }


  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+918375036648',
    );

    if (!await launchUrl(
      phoneUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch phone';
    }
  }

  @override
  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          ListView(

            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome $_firstName $_lastName",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildMenuItem("My Orders", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              }),
              _buildMenuItem("My WishList", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WishlistScreen1()),
                );
              }),
              _buildMenuItem("Address Book", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddressScreen()),
                );
              }),
              _buildMenuItem("Account Information", () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AccountInformationScreen()),
                );

              }),
              _buildMenuItem("Store Credit", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StoreCreditScreen()),
                );

              }),
              _buildMenuItem("Sign Out", () => _signOut(context)),

              // ✅ Delete Account (RED + BOLD)
              _buildMenuItem(
                "Delete Account",
                    () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Delete Account"),
                      content: const Text(
                        "Are you sure you want to delete your account permanently?",
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: const Text("Delete"),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteAccount(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text("customercare@aashniandco.com"),
                onTap: _launchEmail,
              ),

              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text("+91 83750 36648"),
                onTap: _launchPhone,
              ),
            ],
          ),

          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  /// 🔹 Update _buildMenuItem to accept custom textStyle
  Widget _buildMenuItem(
      String title,
      VoidCallback onTap, {
        TextStyle? textStyle,
      }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: textStyle ?? const TextStyle(fontSize: 16),
          ),
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

}




