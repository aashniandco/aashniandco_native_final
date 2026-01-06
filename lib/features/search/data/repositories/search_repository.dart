import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse; // Add this import for HTML parsing
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:aashniandco/features/search/data/models/product_model.dart';
import 'package:http/io_client.dart';


// lib/search/data/repositories/search_repository.dart


import 'dart:convert';
import 'package:http/http.dart' as http;


// lib/features/search/data/repositories/search_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;



// lib/features/search/data/repositories/search_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// ... your model imports

// lib/features/search/data/repositories/search_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:aashniandco/features/search/data/models/product_model.dart';

// lib/features/search/data/repositories/search_repository.dart


import '../../../../constants/api_constants.dart';
import '../models/search_category_model.dart';
import '../models/search_results_model.dart';

class SearchRepository {
  final String _baseUrl = "https://stage.aashniandco.com/rest/V1/aashni";

  Future<SearchResults> fetchProductsByCategory(
      {String? categoryId, String? searchQuery, String sortOption = 'Latest'}) async {

    print("🚀 MAKING API REQUEST FOR Category: $categoryId OR Search: $searchQuery");

    if ((categoryId == null || categoryId.isEmpty) && (searchQuery == null || searchQuery.isEmpty)) {
      throw Exception("Either a categoryId or a searchQuery must be provided.");
    }

    // --- 1. CONSTRUCT THE SOLR QUERY ---
    const String fields = 'designer_name,actual_price_1,short_desc,prod_en_id,prod_small_img,color_name,prod_name,occasion_name,size_name,prod_sku,prod_desc,child_delivery_time';
    String baseQuery;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Build a query for a keyword search
      baseQuery = 'prod_name:(*$searchQuery*) OR designer_name:(*$searchQuery*) OR prod_sku:(*$searchQuery*)';
    } else {
      // Build a query for a category ID
      baseQuery = 'categories-store-1_id:($categoryId)';
    }

    String sortQueryPart;
    switch (sortOption) {
      case 'Price - High To Low': sortQueryPart = 'actual_price_1 desc'; break;
      case 'Price - Low To High': sortQueryPart = 'actual_price_1 asc'; break;
      case 'Latest':
      default:
      // Use a generic sort for search queries, and specific sort for categories
        sortQueryPart = (searchQuery != null && searchQuery.isNotEmpty)
            ? 'score desc, prod_en_id desc'
            : 'cat_position_1_${categoryId} desc, prod_en_id desc';
        break;
    }

    String solrQuery = "{!sort='$sortQueryPart' fl='$fields' rows='24' start='0'}$baseQuery";

    // --- 2. PREPARE AND MAKE THE API CALL ---
    final uri = Uri.parse('${ApiConstants.baseUrl}/V1/solr/search');
    final requestBody = {"queryParams": {"query": solrQuery}};

    print("   Request Body>>>>: ${json.encode(requestBody)}");

    HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print("✅ API RESPONSE RECEIVED. Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> decodedList = json.decode(response.body);
        if (decodedList.length > 1 && decodedList[1] is Map<String, dynamic>) {
          final Map<String, dynamic> resultsData = decodedList[1];
          final List<dynamic> productDocs = resultsData['docs'] ?? [];
          final List<Product1> products = productDocs.map((doc) => Product1.fromSolr(doc)).toList();
          return SearchResults(products: products, categories: []);
        } else {
          return SearchResults(products: [], categories: []);
        }
      } else {
        throw Exception('Failed to load products. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching products: $e');
    }
  }

  Future<SearchResults> searchProducts(String query) async {
    if (query.isEmpty) {
      return SearchResults(products: [], categories: []);
    }

    // ✅ 1. Use the correct API endpoint
    final uri = Uri.parse(
        'https://aashniandco.com/pagelayout/search/autosuggest?q=$query');

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);

        // ✅ 2. Parse the Products
        List<Product1> products = [];
        // The products are nested inside indices -> items
        if (decodedBody['indices'] != null && decodedBody['indices'] is List) {
          final productIndex = decodedBody['indices'].firstWhere(
                (index) => index['identifier'] == 'magento_catalog_product',
            orElse: () => null,
          );
          if (productIndex != null && productIndex['items'] is List) {
            final List<dynamic> productData = productIndex['items'];
            products =
                productData.map((json) => Product1.fromJson(json)).toList();
          }
        }

        // ✅ 3. Parse the Categories from the "SearchCategoryHtml" string
        List<SearchCategory> categories = [];
        final String? categoryHtml = decodedBody['SearchCategoryHtml'];

        if (categoryHtml != null && categoryHtml.isNotEmpty) {
          try {
            var document = parse(categoryHtml);
            // Find all anchor tags within a div with class 'list'
            List<dom.Element> links = document.querySelectorAll('div.list > a');

            for (var link in links) {
              final url = link.attributes['href'] ?? '';
              final spans = link.querySelectorAll('span');

              if (spans.length >= 2) {
                final parentSpanText = spans[0].text.trim();
                final categoryName = spans[1].text.trim();

                // Clean up the parent path by removing the trailing slash
                final parentPath = parentSpanText.replaceAll(
                    RegExp(r'\s*\/\s*$'), '');
                final fullPath = '$parentPath / $categoryName';

                categories.add(SearchCategory(
                  url: url,
                  fullPath: fullPath,
                  categoryName: categoryName,
                  parentPath: parentPath,
                ));
              }
            }
          } catch (e) {
            print("Error parsing category HTML: $e");
            // Fail gracefully if HTML parsing fails
          }
        }

        return SearchResults(products: products, categories: categories);
      } else {
        throw Exception('Failed to load search results. Status code: ${response
            .statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred during search: $e');
    }
  }}
//   Future<SearchResults> searchProducts(String query) async {
//     if (query.isEmpty) {
//       return SearchResults(products: [], categories: []);
//     }
//
//     // ✅ 1. Use the correct API endpoint
//     final uri = Uri.parse('https://stage.aashniandco.com/pagelayout/search/autosuggest?q=$query');
//
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//     IOClient ioClient = IOClient(httpClient);
//
//     try {
//       final response = await ioClient.get(uri);
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> decodedBody = json.decode(response.body);
//
//         // ✅ 2. Parse the Products
//         List<Product> products = [];
//         // The products are nested inside indices -> items
//         if (decodedBody['indices'] != null && decodedBody['indices'] is List) {
//           final productIndex = decodedBody['indices'].firstWhere(
//                 (index) => index['identifier'] == 'magento_catalog_product',
//             orElse: () => null,
//           );
//           if (productIndex != null && productIndex['items'] is List) {
//             final List<dynamic> productData = productIndex['items'];
//             products = productData.map((json) => Product.fromJson(json)).toList();
//           }
//         }
//
//         // ✅ 3. Parse the Categories from the "SearchCategoryHtml" string
//         List<SearchCategory> categories = [];
//         final String? categoryHtml = decodedBody['SearchCategoryHtml'];
//
//         if (categoryHtml != null && categoryHtml.isNotEmpty) {
//           try {
//             var document = parse(categoryHtml);
//             // Find all anchor tags within a div with class 'list'
//             List<dom.Element> links = document.querySelectorAll('div.list > a');
//
//             for (var link in links) {
//               final url = link.attributes['href'] ?? '';
//               final spans = link.querySelectorAll('span');
//
//               if (spans.length >= 2) {
//                 final parentSpanText = spans[0].text.trim();
//                 final categoryName = spans[1].text.trim();
//
//                 // Clean up the parent path by removing the trailing slash
//                 final parentPath = parentSpanText.replaceAll(RegExp(r'\s*\/\s*$'), '');
//                 final fullPath = '$parentPath / $categoryName';
//
//                 categories.add(SearchCategory(
//                   url: url,
//                   fullPath: fullPath,
//                   categoryName: categoryName,
//                   parentPath: parentPath,
//                 ));
//               }
//             }
//           } catch (e) {
//             print("Error parsing category HTML: $e");
//             // Fail gracefully if HTML parsing fails
//           }
//         }
//
//         return SearchResults(products: products, categories: categories);
//       } else {
//         throw Exception('Failed to load search results. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('An error occurred during search: $e');
//     }
// }

// class SearchRepository {
//   final String _baseUrl = "https://stage.aashniandco.com/rest/V1/aashni";
//
//   Future<List<Product>> searchProducts(String query) async {
//     if (query.isEmpty) {
//       return [];
//     }
//
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback =
//         (X509Certificate cert, String host, int port) => true;
//     IOClient ioClient = IOClient(httpClient);
//
//     final uri = Uri.parse('$_baseUrl/filtered-search?q=$query');
//
//     try {
//       final response = await ioClient.get(uri);
//
//       if (response.statusCode == 200) {
//         // Decode the JSON response
//         final List<dynamic> body = json.decode(response.body);
//
//         // --- CORRECTED LOGIC ---
//         // The API returns a list containing another list of products: [[{product1}, {product2}]]
//         // We need to safely access that inner list.
//
//         if (body.isEmpty || body.first is! List) {
//           // If the response is empty or not in the expected [[...]] format, return an empty list.
//           return [];
//         }
//
//         // Access the inner list which contains the product maps
//         final List<dynamic> productData = body.first;
//
//         return productData.map((json) => Product.fromJson(json)).toList();
//
//       } else {
//         throw Exception('Failed to load products. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('An error occurred during search: $e');
//     }
//   }
// }