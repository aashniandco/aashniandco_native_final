import 'package:flutter/material.dart';
class EthnicFilterScreen extends StatefulWidget {
  const EthnicFilterScreen({super.key, required List<Map<String, dynamic>> selectedCategories});

  @override
  State<EthnicFilterScreen> createState() => _EthnicFilterScreenState();
}

class _EthnicFilterScreenState extends State<EthnicFilterScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Ethnic'),
      )
      
    );
  }
}
