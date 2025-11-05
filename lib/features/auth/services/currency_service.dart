import 'package:aashniandco/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import '../data/models/available_currency.dart';
import '../data/models/currency_data.dart';
import '../data/models/currency_info.dart'; // We'll create this model next

// class CurrencyService {
//   final String _baseUrl = "https://stage.aashniandco.com/rest"; // Your Magento base URL
//
//   Future<CurrencyInfo> fetchCurrencyInfo(String ipAddress) async {
//
//     final url = Uri.parse('$_baseUrl/V1/geoip/currency');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'ipAddress': ipAddress}),
//     );
//     // ✅ ADD THIS PRINT STATEMENT
//     print("RAW RESPONSE (GeoIP): ${response.body}");
//     if (response.statusCode == 200) {
//       return CurrencyInfo.fromJson(json.decode(response.body));
//     }
//     throw Exception('Failed to load GeoIP currency info');
//   }
//
//   Future<List<AvailableCurrency>> fetchAvailableCurrencies() async {
//     final url = Uri.parse('$_baseUrl/V1/directory/currencies');
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => AvailableCurrency.fromJson(json)).toList();
//     }
//     throw Exception('Failed to load available currencies');
//   }
// }



class CurrencyService {
  // final String _baseUrl = "https://stage.aashniandco.com/rest";

  // This is now the ONLY method we need.
  Future<CurrencyData> fetchCurrencyData() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/directory/currency');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return CurrencyData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load currency data');
    }
  }
}