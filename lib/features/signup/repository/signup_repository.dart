import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../model/signup_model.dart';

class SignupRepository {
  String baseUrl;

  SignupRepository({required this.baseUrl});

  Future<void> signup(MagentoSignupRequest request) async {
    final url = Uri.parse('https://aashniandco.com/rest/V1/customers');

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    final IOClient ioClient = IOClient(httpClient);

    final response = await ioClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(jsonResponse['message'] ?? "Signup failed");
    }
  }

}
