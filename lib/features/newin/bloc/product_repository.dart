import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../constants/api_constants.dart';
import '../model/new_in_model.dart';
import 'package:http/io_client.dart';

// class ProductRepository {
//   Future<List<Product>> fetchProductsBySubcategory(String subcategory) async {
//     final url = ApiConstants.subcategoryApiMap[subcategory];
//     print('🔗 API Called for "$subcategory": $url');
//
//
//     if (url == null) {
//       throw Exception("API URL not found for subcategory: $subcategory");
//     }
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final items = List<Map<String, dynamic>>.from(data['response']['docs']);
//       return items.map((item) => Product.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to fetch data');
//     }
//   }
// }

/////imp

class ProductRepository {



  // Future<List<Product>> fetchProductsByGenders(List<String> genders) async {
  //   const String url = "https://stage.aashniandco.com/rest/V1/solr/search";
  //
  //   try {
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (cert, host, port) => true;
  //
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     final genderQuery = genders.map((g) => '"$g"').join(" OR ");
  //
  //     final Map<String, dynamic> body = {
  //       "queryParams": {
  //         "query": 'gender_name:($genderQuery)',
  //         "params": {
  //           "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,gender_name",
  //           "rows": "100"
  //         }
  //       }
  //     };
  //
  //     final response = await ioClient.post(
  //       Uri.parse(url),
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);
  //       print('API Response: $decoded');  // Log the entire response to see the structure
  //
  //       final docs = decoded['response']?['docs'];
  //       if (docs is List) {
  //         return docs.map((doc) => Product.fromJson(doc)).toList();
  //       } else {
  //         throw Exception("Invalid docs format");
  //       }
  //     } else {
  //       throw Exception("Failed with status: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("❌ Error fetching gender products: $e");
  //     return [];
  //   }
  // }



  Future<List<Product>> fetchProductsBySubCategoryFilter(List<String> subcat_filter) async {
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final subcat_filterQuery = subcat_filter.map((g) => '"${g.toLowerCase()}"').join(" OR ");


      final Map<String, dynamic> body = {
        "queryParams": {

          "query": 'categories-store-1_name:($subcat_filterQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,prod_desc,child_delivery_time,size_name",
            "rows": "31603",
            "sort": "prod_en_id desc"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print('📥 Raw response body: ${response.body.length > 1000 ? response.body.substring(0, 1000) + '...' : response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();

          // Sort manually by prod_en_id descending
          products.sort((a, b) {
            final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
            final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          // Print top 5 sorted products
          print('\n✅ Top 5 sorted products (prod_en_id descending):');
          for (var product in products.take(10000)) {
            print('• ${product.prodNames?.join("") ?? "N/A"} | prod_en_id: ${product.prod_en_id}| actual_price: ${product.actualPrice}');

          }

          return products;
        } else {
          throw Exception("Invalid docs format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching CategoryFilter products: $e");
      return [];
    }
  }


  Future<List<Product>> fetchProductsByCategoryFilter(List<String> category_filter) async {
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final category_filterQuery = category_filter.map((g) => '"${g.toLowerCase()}"').join(" OR ");


      final Map<String, dynamic> body = {
        "queryParams": {

          "query": 'categories-store-1_name:($category_filterQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,prod_desc,child_delivery_time,size_name",
            "rows": "31603",
            "sort": "prod_en_id desc"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print('📥 Raw response body: ${response.body.length > 1000 ? response.body.substring(0, 1000) + '...' : response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();

          // Sort manually by prod_en_id descending
          products.sort((a, b) {
            final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
            final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          // Print top 5 sorted products
          print('\n✅ Top 5 sorted products (prod_en_id descending):');
          for (var product in products.take(10000)) {
            print('• ${product.prodNames?.join("") ?? "N/A"} | prod_en_id: ${product.prod_en_id}| actual_price: ${product.actualPrice}');

          }

          return products;
        } else {
          throw Exception("Invalid docs format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching CategoryFilter products: $e");
      return [];
    }
  }

  Future<List<Product>> fetchProductsByGenders(List<String> theme) async {
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final themeQuery = theme.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'gender_name:($themeQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,theme_name,prod_desc",
            "rows": "31603",
            // "sort": "prod_en_id desc"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();

          // Sort manually by prod_en_id descending
          products.sort((a, b) {
            final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
            final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          // Print top 5 sorted products
          print('\n✅ Top 5 sorted products (prod_en_id descending):');
          for (var product in products.take(10000)) {
            print('• ${product.prodNames?.join("") ?? "N/A"} | prod_en_id: ${product.prod_en_id}| actual_price: ${product.actualPrice}');

          }

          return products;
        } else {
          throw Exception("Invalid docs format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching Gender products: $e");
      return [];
    }
  }

  Future<List<Product>> fetchProductsByThemes(List<String> theme) async {
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final themeQuery = theme.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'theme_name:($themeQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,theme_name,prod_desc",
            "rows": "31603",
            // "sort": "prod_en_id desc"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();

          // Sort manually by prod_en_id descending
          products.sort((a, b) {
            final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
            final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          // Print top 5 sorted products
          print('\n✅ Top 5 sorted products (prod_en_id descending):');
          for (var product in products.take(10000)) {
            print('• ${product.prodNames?.join("") ?? "N/A"} | prod_en_id: ${product.prod_en_id}| actual_price: ${product.actualPrice}');

          }

          return products;
        } else {
          throw Exception("Invalid docs format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching theme products: $e");
      return [];
    }
  }

  Future<List<Product>> fetchProductsByPrices(List<String> price) async {
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final priceQuery = price.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {

          "queryParams": {
            "query": "actual_price_1:[11 TO 50000] OR actual_price_1:[50000 TO 100000] OR actual_price_1:[100000 TO 150000]OR actual_price_1:[150000 TO 200000] OR actual_price_1:[200000 TO 250000]OR actual_price_1:[250000 TO 300000]OR actual_price_1:[300000 TO 350000]OR actual_price_1:[350000 TO 400000]OR actual_price_1:[400000 TO 450000] OR actual_price_1:[450000 TO 500000]OR actual_price_1:[500000 TO 1500000]",
            "params": {
              "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,shortdesc,occasion_name,prod_desc",
              "rows": "200000",
              "sort": "prod_en_id desc"
            }
          }


      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();

          // Sort manually by prod_en_id descending
          products.sort((a, b) {
            final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
            final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          // Print top 5 sorted products
          print('\n✅ Top 5 sorted products (prod_en_id descending):');
          for (var product in products.take(10000)) {
            print('• ${product.prodNames?.join("") ?? "N/A"} | prod_en_id: ${product.prod_en_id}| actual_price: ${product.actualPrice}');

          }

          return products;
        } else {
          throw Exception("Invalid docs format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching price products: $e");
      return [];
    }
  }




  Future<List<Product>> fetchProductsByColors(List<String> colors) async {
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final colorsQuery = colors.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'color_name:($colorsQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,color_name,size_name,prod_desc,child_delivery_time",
            "rows": "31603",
            // "sort": "prod_en_id desc"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();

          // Sort manually by prod_en_id descending
          products.sort((a, b) {
            final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
            final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          // Print top 5 sorted products
          print('\n✅ Top 5 sorted products (prod_en_id descending):');
          for (var product in products.take(10000)) {
            print('• ${product.prodNames?.join("") ?? "N/A"} | prod_en_id: ${product.prod_en_id}| actual_price: ${product.actualPrice}');

          }

          return products;
        } else {
          throw Exception("Invalid docs format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching Colors products: $e");
      return [];
    }
  }

  Future<List<Product>> fetchProductsBySize(List<String> size) async {
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final sizeQuery = size.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'size_name:($sizeQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,size_name,prod_desc",
            "rows": "31603",
            // "sort": "prod_en_id desc"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();

          // Sort manually by prod_en_id descending
          products.sort((a, b) {
            final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
            final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          // Print top 5 sorted products
          print('\n✅ Top 5 sorted products (prod_en_id descending):');
          for (var product in products.take(10000)) {
            print('• ${product.prodNames?.join("") ?? "N/A"} | prod_en_id: ${product.prod_en_id}| actual_price: ${product.actualPrice}');

          }

          return products;
        } else {
          throw Exception("Invalid docs format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching Sizes products: $e");
      return [];
    }
  }


  Future<List<Product>> fetchProductsByShipin(List<String> shipin) async {
    // const String url = "https://stage.aashniandco.com/rest/V1/solr/search";
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;

      IOClient ioClient = IOClient(httpClient);

      final shipinQuery = shipin.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'child_delivery_time:($shipinQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,size_name,prod_desc",
            "rows": "36000",
            "wt": "json"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();

          // Sort manually by prod_en_id descending
          products.sort((a, b) {
            final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
            final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          // Print top 5 sorted products
          print('\n✅ Top 5 sorted products (prod_en_id descending):');
          for (var product in products.take(10000)) {
            print('• ${product.prodNames?.join("") ?? "N/A"} | prod_en_id: ${product.prod_en_id}| actual_price: ${product.actualPrice}');

          }

          return products;
        } else {
          throw Exception("Invalid docs format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching Shipin products: $e");
      return [];
    }
  }

  Future<List<Product>> fetchProductsByAcoEdit(List<String> acoedit) async {
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final acoeditQuery = acoedit.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'a_co_edit_name:($acoeditQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,a_co_edit_name,prod_desc",
            "rows": "36000",
            // "sort": "prod_en_id desc" // You can leave this if backend doesn't support
          }
        }
      };
      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();

          // Sort manually by prod_en_id descending
          products.sort((a, b) {
            final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
            final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          // Print top 5 sorted products
          print('\n✅ Top 5 sorted products (prod_en_id descending):');
          for (var product in products.take(10000)) {
            print('• ${product.prodNames?.join("") ?? "N/A"} | prod_en_id: ${product.prod_en_id}| actual_price: ${product.actualPrice}');

          }

          return products;
        } else {
          throw Exception("Invalid docs format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching Acoedit products: $e");
      return [];
    }
  }

  Future<List<Product>> fetchProductsByOccassions(List<String> occassions) async {
    final uri = Uri.parse(ApiConstants.url);
    print('🎯 Fetching by occasions: $occassions');
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final occassionsQuery = occassions.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'occasion_name:($occassionsQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,size_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,occasion_name,prod_desc",
            "rows": "36000",
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // Print full or partial raw response body
      print('📥 Raw response body: ${response.body.length > 1000 ? response.body.substring(0, 1000) + '...' : response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('🧩 Decoded JSON: $decoded');

        if (decoded is List && decoded.length > 1) {
          final secondItem = decoded[1];

          if (secondItem is Map && secondItem.containsKey('docs')) {
            final docs = secondItem['docs'];

            if (docs is List) {
              print('📄 Total docs returned: ${docs.length}');

              if (docs.isEmpty) {
                print('⚠️ No products found for these occasions.');
                return [];
              }

              final products = docs.map((doc) => Product.fromJson(doc)).toList();

              // Sort manually by prod_en_id descending
              products.sort((a, b) {
                final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
                final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
                return idB.compareTo(idA);
              });

              // ✅ Print all sorted products
              print('\n✅ All sorted products (prod_en_id descending):');
              for (var product in products) {
                print('• ${product.prodNames?.join("") ?? "N/A"} | prod_en_id: ${product.prod_en_id} | actual_price: ${product.actualPrice}');
              }

              return products;
            } else {
              throw Exception("Expected 'docs' to be a List.");
            }
          } else {
            throw Exception("Second item missing 'docs' key or invalid structure.");
          }
        } else {
          throw Exception("Response is not a valid List or missing second element.");
        }
      } else {
        throw Exception("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching occasion_name products: $e");
      return [];
    }
  }

  Future<List<Product>> fetchProductsForMultipleSubcategories(List<String> subcategories) async {
    List<Product> allProducts = [];

    for (String subcategory in subcategories) {
      try {
        final products = await fetchProductsBySubcategory(subcategory);
        allProducts.addAll(products);
      } catch (e) {
        print("⚠️ Failed to fetch for $subcategory: $e");
        // Continue fetching others even if one fails
      }
    }

    return allProducts;
  }

  Future<List<Product>> fetchProductsBySubcategory(String subcategory) async {
    // Await the URL fetching, since it’s asynchronous
    final url = await ApiConstants.getApiUrlForSubcategory(subcategory.toLowerCase());
    print("📦 Fetching from: $url");

    // Ensure the URL is not empty
    if (url.isEmpty) {
      throw Exception("API URL is empty for subcategory: $subcategory");
    }

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      final response = await ioClient.get(Uri.parse(url));
      print("📡 Status Code: ${response.statusCode}");
      print("📨 Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic rawJson = json.decode(response.body);

        if (rawJson is List && rawJson.length > 1) {
          final secondObject = rawJson[1] as Map<String, dynamic>;

          final solrResponse = SolrProductResponse.fromJson({'response': secondObject});
          print("✅ Parsed ${solrResponse.products.length} products");

          for (var p in solrResponse.products) {
            print("🧵 ${p.designerName} - ₹${p.actualPrice} - ${p.shortDesc}");
          }

          return solrResponse.products;
        } else {
          print("⚠️ Unexpected format: $rawJson");
          throw Exception("Unexpected response format from API");
        }
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to load products from API");
      }
    } catch (e, stackTrace) {
      print("🔥 Exception occurred: $e");
      print("📍 StackTrace: $stackTrace");
      throw Exception("Error fetching products: $e");
    }
  }
}
// class ProductRepository {
//
//   Future<List<Product>> fetchProductsForMultipleSubcategories(List<String> subcategories) async {
//     List<Product> allProducts = [];
//
//     for (String subcategory in subcategories) {
//       try {
//         final products = await fetchProductsBySubcategory(subcategory);
//         allProducts.addAll(products);
//       } catch (e) {
//         print("⚠️ Failed to fetch for $subcategory: $e");
//         // Continue fetching others even if one fails
//       }
//     }
//
//     return allProducts;
//   }
//
//
//   Future<List<Product>> fetchProductsBySubcategory(String subcategory) async {
//     final url = ApiConstants.getApiUrlForSubcategory(subcategory.toLowerCase());
//     print("📦 Fetching from: $url");
//
//     if (url.isEmpty) {
//       throw Exception("API URL is empty for subcategory: $subcategory");
//     }
//
//     try {
//       HttpClient httpClient = HttpClient();
//             httpClient.badCertificateCallback = (cert, host, port) => true;
//             IOClient ioClient = IOClient(httpClient);
//       // final response = await ioClient.get(url, headers: {"Connection": "keep-alive"});
//       final response = await ioClient.get(Uri.parse(url));
//       print("📡 Status Code: ${response.statusCode}");
//       print("📨 Raw Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final dynamic rawJson = json.decode(response.body);
//
//         if (rawJson is List && rawJson.length > 1) {
//           final secondObject = rawJson[1] as Map<String, dynamic>;
//
//           final solrResponse = SolrProductResponse.fromJson({'response': secondObject});
//           print("✅ Parsed ${solrResponse.products.length} products");
//
//           for (var p in solrResponse.products) {
//             print("🧵 ${p.designerName} - ₹${p.actualPrice} - ${p.shortDesc}");
//           }
//
//           return solrResponse.products;
//         } else {
//           print("⚠️ Unexpected format: $rawJson");
//           throw Exception("Unexpected response format from API");
//         }
//       } else {
//         print("❌ Error: ${response.statusCode} - ${response.body}");

//         throw Exception("Failed to load products from API");
//       }
//     } catch (e, stackTrace) {
//       print("🔥 Exception occurred: $e");
//       print("📍 StackTrace: $stackTrace");
//       throw Exception("Error fetching products: $e");
//     }
//   }
// }



