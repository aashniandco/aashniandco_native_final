import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.grey,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    ),
  );
}
