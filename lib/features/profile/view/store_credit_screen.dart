import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../../constants/api_constants.dart'; // For formatting date and currency

// Assume ApiConstants is defined somewhere

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// adjust path to your ApiConstants

class StoreCreditScreen extends StatefulWidget {
  const StoreCreditScreen({super.key});

  @override
  State<StoreCreditScreen> createState() => _StoreCreditScreenState();
}

class _StoreCreditScreenState extends State<StoreCreditScreen> {
  double _balance = 0.0;
  List<dynamic> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStoreCreditData();
  }

  Future<void> _fetchStoreCreditData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    if (token == null) {
      setState(() {
        _errorMessage = "You are not logged in.";
        _isLoading = false;
      });
      return;
    }

    try {
      // ---- Fetch Balance ----
      final balanceResponse = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/V1/aashni-mobileapi/customer/storecredit/balance"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (balanceResponse.statusCode == 200) {
        final body = balanceResponse.body.trim();
        // Sometimes Magento returns raw float/string
        _balance = double.tryParse(body) ?? 0.0;
      } else {
        throw Exception("Failed to load balance: ${balanceResponse.body}");
      }

      // ---- Fetch History ----
      final historyResponse = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/V1/aashni-mobileapi/customer/storecredit/history"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (historyResponse.statusCode == 200) {
        final decoded = json.decode(historyResponse.body);
        if (decoded is List) {
          _history = decoded;
        } else if (decoded is Map && decoded.containsKey('items')) {
          // In case Magento wraps results in "items"
          _history = decoded['items'];
        } else {
          _history = [];
        }
      } else {
        throw Exception("Failed to load history: ${historyResponse.body}");
      }
    } catch (e) {
      _errorMessage = "Error fetching store credit data: $e";
      debugPrint(_errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Credit"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchStoreCreditData,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ---- Balance Card ----
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Balance",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(_balance),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Transaction History",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(height: 20, thickness: 1),
          _history.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "No transaction history found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final item = _history[index] as Map<String, dynamic>;
              final action = item['action']?.toString() ?? 'N/A';
              final amount = double.tryParse(item['balance_amount']?.toString() ?? "0") ?? 0.0;
              final createdAt = item['created_at'] != null
                  ? DateTime.tryParse(item['created_at'].toString())
                  : null;
              final currentBalance =
                  double.tryParse(item['current_balance']?.toString() ?? "0") ?? 0.0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Amount: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount)}",
                        style: TextStyle(
                          color: amount >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Balance after: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(currentBalance)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (createdAt != null)
                        Text(
                          "Date: ${DateFormat('MMM d, yyyy h:mm a').format(createdAt)}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
