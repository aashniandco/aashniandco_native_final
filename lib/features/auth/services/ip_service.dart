import 'package:http/http.dart' as http;
import 'dart:convert';

class IpService {
  final _ipApiUrl = Uri.parse('https://api.ipify.org?format=json');


  Future<String> getPublicIpAddress() async {
  final response = await http.get(_ipApiUrl);
  if (response.statusCode == 200) {
  return json.decode(response.body)['ip'];
  }
  throw Exception('Failed to fetch IP address');
  }
  }
  // Future<String> getPublicIpAddress() async {
  //   try {
  //     final response = await http.get(_ipApiUrl);
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return data['ip']; // e.g., "114.143.109.126"
  //     }
  //     throw Exception('Failed to fetch IP');
  //   } catch (e) {
  //     throw Exception('Could not determine IP address.');
  //   }
  // }
