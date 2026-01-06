import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/megamenu_model.dart';
import 'package:http/io_client.dart';

import 'dart:convert'; // Make sure json is imported

import 'package:http/io_client.dart';
import 'package:aashniandco/features/categories/model/megamenu_model.dart'; // Adjust import if needed

class MegamenuRepository {
  final String baseUrl = 'https://aashniandco.com/rest/V1/solr/megamenu';

  Future<MegamenuModel> fetchMegamenu() async {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);
    final response = await ioClient.get(Uri.parse(baseUrl));

    // --- ADD THIS LINE TO PRINT THE RAW RESPONSE BODY ---
    // This will print the full JSON string that comes back from the server.
    print("✅ Megamenu API Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // (Optional) You can also print the data after it has been decoded into Dart objects.
      print("✅ Megamenu Decoded Data: $decoded");

      return MegamenuModel.fromJson(decoded);
    } else {
      // It's also helpful to print the body on failure, as it might contain an error message.
      print("❌ Megamenu API Error - Status: ${response.statusCode}, Body: ${response.body}");
      throw Exception('Failed to load megamenu');
    }
  }
}

// class MegamenuRepository {
//   final String baseUrl = 'https://stage.aashniandco.com/rest/V1/solr/megamenu';
//
//
//   Future<MegamenuModel> fetchMegamenu() async {
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//     final response = await ioClient .get(Uri.parse(baseUrl));
//
//     if (response.statusCode == 200) {
//       final decoded = json.decode(response.body);
//       return MegamenuModel.fromJson(decoded);
//     } else {
//       throw Exception('Failed to load megamenu');
//     }
//   }
// }
