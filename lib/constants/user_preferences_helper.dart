  import 'dart:ffi';

  import 'package:shared_preferences/shared_preferences.dart';
  class UserPreferences {
    static Future<String> getFirstName() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_firstname') ?? '';
    }

    static Future<String> getLastName() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_lastname') ?? '';
    }


    static Future<int?> getCustomerId() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('user_customer_id'); // returns null if not found
    }

    static Future<String?> getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_token');
    }
  }
