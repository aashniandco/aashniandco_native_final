// lib/api/product_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:http/io_client.dart';

// lib/api/product_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;


import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';


// lib/api/product_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:http/io_client.dart';

import '../model/api_response.dart';

class ProductRepository1 {
  final String _baseUrl = "stage.aashniandco.com";

  Future<SolrApiResponse> getProductsAndFilters({
    required int categoryId,
    Map<String, List<String>>? filters,
    Map<String, String> sortParams = const {},
    // String? sort,
    // String? direction,
    int pageSize = 20, // ✅ CHANGED: Use a reasonable page size for API calls
    int currentPage = 1,
    // ❗️ REMOVED: The isScroll parameter is no longer needed for pagination
    // bool isScroll = false,
    bool fetchAll = false,
  }) async {
    final queryParameters = {
      'pageSize': pageSize.toString(),
      'currentPage': currentPage.toString(),
      'isScroll': fetchAll.toString(),
      // ❗️ REMOVED: 'isScroll': isScroll.toString(),
    };
    queryParameters.addAll(sortParams);
    // ✅ CHANGED: The API expects the sort option directly as a parameter
    // if (sort != null && sort.isNotEmpty) {
    //   queryParameters['sort'] = sort;
    //   if (direction != null && direction.isNotEmpty) {
    //     queryParameters['dir'] = direction;
    //   }
    // }

    if (filters != null && filters.isNotEmpty) {
      queryParameters['filters'] = json.encode(filters);
    }

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(httpClient);

    final uri = Uri.https(
        _baseUrl, '/rest/V1/solr/category/$categoryId/products', queryParameters);

    // ✅✅✅ THIS IS THE CRITICAL DEBUGGING LINE ✅✅✅
    print("--- FETCHING API ---");
    print("URI: $uri");
    print("--------------------");

    try {
      final response = await ioClient.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> decodedBody = json.decode(response.body);

        if (decodedBody.length < 5) {
          throw Exception('Invalid API response format: Unexpected number of elements.');
        }

        final Map<String, dynamic> responseMap = {
          'success': decodedBody[0],
          'products': decodedBody[1],
          'filters': decodedBody[2],
          'total_count': decodedBody[3],
          'pagination': decodedBody[4],
        };

        return SolrApiResponse.fromJson(responseMap);
      } else {
        throw Exception('Failed to load products. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred during API call: $e');
    } finally {
      ioClient.close();
    }
  }
}