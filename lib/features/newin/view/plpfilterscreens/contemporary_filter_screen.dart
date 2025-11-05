import 'package:flutter/material.dart';
class ContemporaryFilterScreen extends StatefulWidget {
  const ContemporaryFilterScreen({super.key, required List<Map<String, dynamic>> selectedCategories});

  @override
  State<ContemporaryFilterScreen> createState() => _ContemporaryFilterScreenState();
}

class _ContemporaryFilterScreenState extends State<ContemporaryFilterScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Contemorary'),
      )
      
    );
  }
}
