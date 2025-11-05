import 'package:flutter/material.dart';

class DummyProductScreen extends StatelessWidget {
  final String url;

  const DummyProductScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Page")),
      body: Center(
        child: Text(
          "Navigated to product:\n\n$url",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
