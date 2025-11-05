
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';
import '../../categories/model/filter_model.dart';
import '../../newin/model/new_in_model.dart';

import 'package:http/io_client.dart';



class ApiService
{
  final String _baseUrl = "https://stage.aashniandco.com/rest/V1";
  // --- NEW METHOD TO FETCH PRODUCTS FROM SOLR ---


  /// Fetches the list of available filter types (e.g., Designer, Color) for a category.
  Future<List<FilterType>> fetchAvailableFilterTypes(String categoryId) async {
    // Whitelist of filters to display, in the desired order.
    const Map<String, String> allowedFiltersMap = {
      'themes': 'Themes',
      'categories': 'Category',
      'designers': 'Designer',
      'colors': 'Color',
      'sizes': 'Size',
      'delivery_times': 'Delivery',
      'price': 'Price',
      'a_co_edit': 'A+CO Edits',
      'occasions': 'Occasions'
    };

    final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category/$categoryId/filters');

    try {
      HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      final response = await ioClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);

        // ✅ FIX: Consistently parse the API response by getting the first key of each map object.
        // This logic now matches the parsing strategy in `fetchGenericFilter`.
        final availableApiKeys = rawData
            .whereType<Map<String, dynamic>>()
            .where((item) => item.isNotEmpty) // Ensure the map isn't empty
            .map((item) => item.keys.first)
            .toSet(); // e.g., {'sizes', 'colors', 'occasions', 'child_categories'}

        final List<FilterType> result = [];
        for (var entry in allowedFiltersMap.entries) {
          final String filterKey = entry.key;
          final String label = entry.value;

          // Check if our whitelisted filter key is present in the API response
          if (availableApiKeys.contains(filterKey)) {
            // ✅ FIX: Create FilterType instance using 'key' to match the model
            result.add(FilterType(key: filterKey, label: label));
          }
        }
        return result;
      } else {
        throw Exception('Failed to load filter types: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching filter types: $e');
      throw Exception('An error occurred while loading filters.');
    }
  }

  /// Fetches the specific items for a given filter type (e.g., all available Designers).
// In your ApiService class

// In your ApiService class

// In your ApiService.dart file

// In your ApiService.dart file

  Future<List<FilterItem>> fetchGenericFilter({
    required String categoryId,
    required String filterType,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category/$categoryId/filters');

    try {
      HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      final response = await ioClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);
        final List<FilterItem> itemList = [];
        Map<String, dynamic> childCategoriesData = {};

        for (var item in rawData) {
          if (item is! Map<String, dynamic>) continue;

          if (filterType == 'categories' && item.containsKey('child_categories')) {
            childCategoriesData = item['child_categories'];
          }

          if (item.containsKey(filterType)) {
            print("Found filter data for '$filterType'. Determining format...");
            final dynamic filterValue = item[filterType]; // Use 'dynamic' to hold either Map or List

            // ✅ NEW: CHECK THE FORMAT OF THE DATA

            // --- FORMAT 1: The value is a MAP (like for 'sizes', 'designers') ---
            if (filterValue is Map<String, dynamic>) {
              print("Parsing as Map format.");
              final Map<String, dynamic> filterData = filterValue;
              filterData.forEach((key, value) {
                final String valueString = value.toString();
                final parts = valueString.split('|');

                String finalId;
                String finalName;

                if (parts.length == 2) {
                  finalId = parts[0].trim();
                  finalName = parts[1].trim();
                } else {
                  finalId = key;
                  finalName = valueString;
                }

                List<FilterItem> children = [];
                if (filterType == 'categories' && childCategoriesData.containsKey(key)) {
                  final Map<String, dynamic> childMap = childCategoriesData[key];
                  childMap.forEach((childId, childName) {
                    children.add(FilterItem(id: childId, name: childName));
                  });
                }

                itemList.add(FilterItem(id: finalId, name: finalName, children: children));
              });
            }
            // --- FORMAT 2: The value is a LIST (like for 'occasions') ---
            else if (filterValue is List) {
              print("Parsing as List format.");
              final List<dynamic> filterList = filterValue;
              for (var option in filterList) {
                if (option is Map<String, dynamic>) {
                  final String? id = option['id']?.toString();
                  final String? name = option['name']?.toString();

                  if (id != null && name != null) {
                    itemList.add(FilterItem(id: id, name: name));
                  }
                }
              }
            }
          }
        }
        return itemList;
      } else {
        throw Exception('Failed to load filter: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching filter type "$filterType": $e');
      throw Exception('Failed to load filter data.');
    }
  }


  // ✅ NEW METHOD TO FETCH CATEGORY METADATA
  // ✅ FINAL ROBUST METHOD - HANDLES UNEXPECTED ARRAY RESPONSE
  Future<Map<String, dynamic>> fetchCategoryMetadataByName(String categoryName) async {
    final urlKey = categoryName
        .toLowerCase()
        .replaceAll("'", "")
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');

    final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category-by-url-key/$urlKey');
    print('newinCattabRequesting Category Metadata from URL: $url');

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.get(url);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);

        // --- PARSING LOGIC FOR THE SPECIFIC ARRAY RESPONSE ---
        if (decodedBody is List && decodedBody.length >= 5) {
          print("API returned a List. Parsing based on fixed order.");

          // Manually build the Map that the app expects, based on the known order.
          // ["Men", 2, "men", 1381, 1371]
          //  [0]    [1]   [2]    [3]    [4]
          // We use .toString() to be safe with types.
          return {
            'cat_name': decodedBody[0].toString(),
            'cat_level': decodedBody[1], // Assuming this is an int
            'cat_url_key': decodedBody[2].toString(),
            'pare_cat_id': decodedBody[3].toString(),
            'cat_id': decodedBody[4].toString(), // This is the crucial ID
          };

        } else if (decodedBody is Map<String, dynamic>) {
          // Fallback for if the API ever gets fixed to return a proper map
          print("API returned a Map as expected.");
          return decodedBody;
        } else {
          // If the response is neither a valid list nor a map, throw an error.
          throw Exception('API returned an unexpected data format that could not be parsed.');
        }

      } else {
        // ... existing error handling for non-200 status codes ...
        String errorMessage = 'Category not found: $categoryName';
        try {
          final decodedError = json.decode(response.body);
          if (decodedError['message'] != null) { errorMessage = decodedError['message']; }
        } catch (_) { errorMessage = response.body; }
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      // ... existing catch block ...
      print('--- ERROR FETCHING CATEGORY METADATA ---');
      print('Exception Type: ${e.runtimeType}');
      print('Exception Object: $e');
      print('Stack Trace: \n$stackTrace');
      print('--- END ERROR ---');
      throw Exception('Could not load category details. Please check the debug console.');
    } finally {
      ioClient.close();
    }
  }




}