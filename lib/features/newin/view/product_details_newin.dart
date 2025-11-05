import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:aashniandco/features/wishlist/view/wishlist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../../../constants/user_preferences_helper.dart';
import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import '../../auth/view/wishlist_screen.dart';
import '../../cart/view/cart.dart';
import '../../categories/model/product_image.dart';
import '../../categories/repository/api_service.dart';
import '../../checkout/checkout_screen.dart';
import '../../shoppingbag/shopping_bag.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../wishlist/repository/wishlist_api_service.dart';
import '../model/new_in_model.dart';  // Adjust import based on where your Product model is located

class ProductDetailNewInDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;






  const ProductDetailNewInDetailScreen({Key? key, required this.product}) : super(key: key);


  @override
  State<ProductDetailNewInDetailScreen> createState() => _ProductDetailNewInDetailScreenState();
}


class _ProductDetailNewInDetailScreenState extends State<ProductDetailNewInDetailScreen> {
  // int selectedSizeIndex = 0; // Default selected size
  int selectedSizeIndex = -1;
  String selectedSizeApiValue = '';    // Holds the full name for the API (e.g., "Small")
  String selectedSizeDisplayValue = ''; // Holds the short name for the UI (e.g., "S")
  Map<String, String> sizeOptions = {}; // Holds Display Value -> API Value mapping

  String firstName = '';
  String lastName = '';
  int customer_id = 0;
  int cartQty = 0;
  bool _isAddingToWishlist = false;
  final WishlistApiService _wishlistApiService = WishlistApiService();
  late PageController _pageController;
  List<ProductImage> _productImages = [];
  bool _areImagesLoading = true;
  bool _areDetailsLoading = true;
  String _fetchedProductDesc = '';
  String _fetchedDeliveryTime = '';
  late TransformationController _transformationController;
  double _currentScale = 1.0;

  TapDownDetails? _doubleTapDetails;

  List<String> _sizeList = []; // To hold the list of size labels like "S", "M", etc.
  String? _errorMessage; // To hold an error message if the API call fails

  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _youMayAlsoLikeProducts = [];

  bool _isLoadingSuggestions = true;
  bool _isLoadingDesigner = true;
  List<Map<String, dynamic>> _designerProducts = []; // parag

  int? _totalDesignerProducts;
  int _designerOffset = 0;
  final int _designerPageSize = 10;
  bool _isFetchingMoreDesigner = false;
  bool _hasMoreDesigner = true;
  final ScrollController _designerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCartQuantity();
    _pageController = PageController();
    _parseAndSetSizes();
    _loadUserNames();
    _fetchAndApplyFullProductDetails();
    _fetchProductImages();
    _fetchYouMayAlsoLikeSuggestions();


    _transformationController = TransformationController();
    _transformationController.addListener(_onScaleUpdate);

    // Start fetching designer products
    _fetchMoreFromDesigner();

    _designerScrollController.addListener(() {
      if (_designerScrollController.position.pixels >=
          _designerScrollController.position.maxScrollExtent - 200 &&
          !_isFetchingMoreDesigner &&
          _hasMoreDesigner) {
        _fetchMoreFromDesigner(isPaginating: true);
      }
    });


  }


  String  _buildDesignerRequestBody(String designerName) {
    const String fieldsToFetch =
        'designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,prod_image_url,short_desc,actual_price_1';

    final String sortString = "prod_en_id desc"; // Default: latest first
    final String filter = 'designer_name:"$designerName"';

    final String solrQuery =
        "{!sort='$sortString' fl='$fieldsToFetch' rows='$_designerPageSize' start='$_designerOffset'}$filter";

    final Map<String, dynamic> requestBody = {
      "queryParams": {"query": solrQuery}
    };
    return json.encode(requestBody);
  }
// In _ProductDetailNewInDetailScreenState


  Future<void> _fetchMoreFromDesigner({bool isPaginating = false}) async {
    if ((_totalDesignerProducts != null &&
        _designerProducts.length >= _totalDesignerProducts!) ||
        _isFetchingMoreDesigner) {
      return;
    }

    setState(() {
      if (isPaginating) {
        _isFetchingMoreDesigner = true;
      } else {
        _isLoadingDesigner = true;
      }
    });

    final url = Uri.parse('https://aashniandco.com/rest/V1/solr/search');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);

      final requestBody =
      _buildDesignerRequestBody(widget.product['designer_name'] ?? '');

      final response = await ioClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.length > 1 && data[1]['docs'] is List) {
          if (_totalDesignerProducts == null) {
            _totalDesignerProducts = data[1]['numFound'] as int?;
          }
          List<dynamic> newProducts = data[1]['docs'];
          // Cast each item to Map<String, dynamic>
          // ✅ --- START OF CHANGE --- ✅
          // Cast each item and filter out products where the price is 0 or 1
          List<Map<String, dynamic>> newProductsCasted = newProducts
              .map((e) => Map<String, dynamic>.from(e))
              .where((product) {
            // Safely get the price, defaulting to 0.0 if null
            final price = (product['actual_price_1'] as num?)?.toDouble() ?? 0.0;
            // Keep the product only if the price is greater than 1
            return price > 1;
          }).toList();
          // ✅ --- END OF CHANGE --- ✅
          if (mounted) {
            setState(() {
              _designerProducts.addAll(newProductsCasted);
              _designerOffset += newProductsCasted.length;
              if (_totalDesignerProducts != null &&
                  _designerProducts.length >= _totalDesignerProducts!) {
                _hasMoreDesigner = false;
              }
              if (newProductsCasted.length < _designerPageSize) {
                _hasMoreDesigner = false;
              }
            });
          }
        } else {
          if (mounted) setState(() => _hasMoreDesigner = false);
        }
      } else {
        throw Exception('Failed to load more from designer');
      }
    } catch (e) {
      print('Error fetching more from designer: $e');
      if (mounted) setState(() => _hasMoreDesigner = false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDesigner = false;
          _isFetchingMoreDesigner = false;
        });
      }
    }
  }

  // In your _ProductDetailNewInDetailScreenState class



  Future<void> _fetchYouMayAlsoLikeSuggestions() async {
    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final patternName = widget.product['patterns_name']?.toString() ?? '';
      final genderName = widget.product['gender_name']?.toString() ?? '';
      final kidName = widget.product['kid_name']?.toString() ?? '';

      // 🧩 Clean up pattern name (remove brackets if it's a list string like [Kurta Sets])
      final cleanPattern = patternName
          .replaceAll(RegExp(r'[\[\]]'), '')
          .trim();

      // 🧩 Add quotes if the pattern name has spaces
      final formattedPattern = cleanPattern.contains(' ')
          ? '"$cleanPattern"'
          : cleanPattern;

      // 🧠 Build Solr query
      String customQuery = '';

      if (formattedPattern.isNotEmpty && genderName.isNotEmpty) {
        customQuery = 'patterns_name:$formattedPattern AND gender_name:$genderName';
      } else if (formattedPattern.isNotEmpty && kidName.isNotEmpty) {
        customQuery = 'patterns_name:$formattedPattern AND kid_name:$kidName';
      } else if (formattedPattern.isNotEmpty) {
        customQuery = 'patterns_name:$formattedPattern';
      } else {
        final shortDesc = widget.product['short_desc']?.toString() ?? '';
        customQuery = shortDesc;
      }

      print('🟡 Sending Custom Query: $customQuery');

      final suggestions = await _apiService.fetchSuggestionsByShortDesc(customQuery);

      if (mounted) {
        final filteredSuggestions = suggestions.where((product) {
          final price = (product['actual_price_1'] as num?)?.toDouble() ?? 0.0;
          return price > 1;
        }).toList();

        setState(() {
          _youMayAlsoLikeProducts = filteredSuggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching "You may also like" suggestions: $e');
      }
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
        });
      }
    }
  }


  //3/11/2025
  // Future<void> _fetchYouMayAlsoLikeSuggestions() async {
  //   setState(() {
  //     _isLoadingSuggestions = true;
  //   });
  //
  //   try {
  //     // 🟢 Get product info
  //     final patternName = widget.product['patterns_name']?.toString() ?? '';
  //     final genderName = widget.product['gender_name']?.toString() ?? '';
  //     final kidName = widget.product['kid_name']?.toString() ?? '';
  //
  //     // 🧩 Build a custom Solr-style query string
  //     // (This will be passed as skuData in the POST body)
  //     String customQuery = '';
  //
  //     if (patternName.isNotEmpty && genderName.isNotEmpty) {
  //       customQuery = 'patterns_name:$patternName AND gender_name:$genderName';
  //     } else if (patternName.isNotEmpty && kidName.isNotEmpty) {
  //       customQuery = 'patterns_name:$patternName AND kid_name:$kidName';
  //     } else if (patternName.isNotEmpty) {
  //       customQuery = 'patterns_name:$patternName';
  //     } else {
  //       // fallback to short_desc if pattern not available
  //       final shortDesc = widget.product['short_desc']?.toString() ?? '';
  //       customQuery = shortDesc;
  //     }
  //
  //     print('🟡 Sending Custom Query: $customQuery');
  //
  //     // 🔥 Call your existing API service
  //     final suggestions = await _apiService.fetchSuggestionsByShortDesc(customQuery);
  //
  //     if (mounted) {
  //       // ✅ --- START OF CHANGE --- ✅
  //       // Filter the suggestions to remove products with a price of 0 or 1
  //       final filteredSuggestions = suggestions.where((product) {
  //         final price = (product['actual_price_1'] as num?)?.toDouble() ?? 0.0;
  //         return price > 1;
  //       }).toList();
  //       // ✅ --- END OF CHANGE --- ✅
  //
  //       setState(() {
  //         _youMayAlsoLikeProducts = suggestions;
  //         _isLoadingSuggestions = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('❌ Error fetching "You may also like" suggestions: $e');
  //     }
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingSuggestions = false;
  //       });
  //     }
  //   }
  // }

//1/11/2025
  // Future<void> _fetchYouMayAlsoLikeSuggestions() async {
  //   setState(() {
  //     _isLoadingSuggestions = true;
  //   });
  //
  //   try {
  //     // 1️⃣ Get the product's short description
  //     final shortDesc = widget.product['short_desc']?.toString() ?? '';
  //     final words = shortDesc.split(' ').where((w) => w.isNotEmpty).toList();
  //
  //     List<String> fallbackQueries = [];
  //
  //     if (words.isNotEmpty) {
  //       // Prepare last 3, 2, and 1 word(s) queries
  //       if (words.length >= 3) {
  //         fallbackQueries.add(
  //             '${words[words.length - 3]} ${words[words.length - 2]} ${words[words.length - 1]}');
  //       }
  //       // if (words.length >= 2) {
  //       //   fallbackQueries.add('${words[words.length - 2]} ${words[words.length - 1]}');
  //       // }
  //       // fallbackQueries.add(words[words.length - 1]); // last word
  //     }
  //
  //     List<Map<String, dynamic>> suggestions = [];
  //
  //     // 2️⃣ Try each fallback query until we get results
  //     for (final query in fallbackQueries) {
  //       if (query.isEmpty) continue;
  //
  //       print('Trying query: $query');
  //
  //       suggestions = await _apiService.fetchSuggestionsByShortDesc(query);
  //
  //       if (suggestions.isNotEmpty) {
  //         break; // stop if we got suggestions
  //       }
  //     }
  //
  //     if (mounted) {
  //       setState(() {
  //         _youMayAlsoLikeProducts = suggestions;
  //         _isLoadingSuggestions = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (kDebugMode) print('Error fetching "You may also like" suggestions: $e');
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingSuggestions = false;
  //       });
  //     }
  //   }
  // }

  // Future<void> _fetchYouMayAlsoLikeSuggestions() async {
  //   setState(() {
  //     _isLoadingSuggestions = true;
  //   });
  //
  //   try {
  //     // 1️⃣ Get the product's short description
  //     final shortDesc = widget.product['short_desc']?.toString() ?? '';
  //     final words = shortDesc.split(' ').where((w) => w.isNotEmpty).toList();
  //
  //     List<String> fallbackQueries = [];
  //
  //     if (words.isNotEmpty) {
  //       // Prepare last 3, 2, and 1 word(s) queries
  //       if (words.length >= 3) {
  //         fallbackQueries.add(
  //             '${words[words.length - 3]} ${words[words.length - 2]} ${words[words.length - 1]}');
  //       }
  //       if (words.length >= 2) {
  //         fallbackQueries.add('${words[words.length - 2]} ${words[words.length - 1]}');
  //       }
  //       fallbackQueries.add(words[words.length - 1]); // last word
  //     }
  //
  //     List<Map<String, dynamic>> suggestions = [];
  //
  //     // 2️⃣ Try each fallback query until we get results
  //     for (final query in fallbackQueries) {
  //       if (query.isEmpty) continue;
  //
  //       print('Trying query: $query');
  //
  //       suggestions = await _apiService.fetchSuggestionsByShortDesc(query);
  //
  //       if (suggestions.isNotEmpty) {
  //         break; // stop if we got suggestions
  //       }
  //     }
  //
  //     if (mounted) {
  //       setState(() {
  //         _youMayAlsoLikeProducts = suggestions;
  //         _isLoadingSuggestions = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (kDebugMode) print('Error fetching "You may also like" suggestions: $e');
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingSuggestions = false;
  //       });
  //     }
  //   }
  // }







  void _handleDoubleTap() {
    // If there are no tap details, do nothing.
    if (_doubleTapDetails == null) return;

    // Define the zoom factor
    const double zoomFactor = 3.0;

    // Check if the image is currently zoomed in.
    if (_transformationController.value != Matrix4.identity()) {
      // If it is zoomed in, animate back to the default (zoomed out) state.
      _transformationController.value = Matrix4.identity();
    } else {
      // If it is zoomed out, zoom in to the point where the user tapped.
      final position = _doubleTapDetails!.localPosition;

      // Animate to a new matrix that is translated and scaled.
      // This formula centers the zoom on the tapped point.
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * (zoomFactor - 1), -position.dy * (zoomFactor - 1))
        ..scale(zoomFactor);
    }
  }
  Future<void> _fetchProductImages() async {
    final sku = widget.product['prod_sku'];
    if (sku == null || sku.toString().isEmpty) {
      print("Error: SKU is missing. Cannot fetch images.");
      if (mounted) setState(() => _areImagesLoading = false);
      return;
    }

    try {
      final images = await _apiService.fetchProductImages(sku.toString());
      if (mounted) {
        setState(() {
          // Filter out any disabled images and update the state
          _productImages = images.where((img) => !img.isDisabled).toList();
          _areImagesLoading = false;
        });
      }
    } catch (e) {
      print("Could not fetch product images from API: $e");
      if (mounted) {
        setState(() {
          _areImagesLoading = false; // Stop loading even if there's an error
        });
      }
    }
  }



  Future<void> _fetchAndApplyFullProductDetails() async {
    // Get the SKU from the initial product data passed to the widget.
    // 'prod_sku' is the correct field name from your Solr index.
    final sku = widget.product['prod_sku'];

    if (sku == null || sku.toString().isEmpty) {
      print("Error: SKU is missing from the initial product data. Cannot fetch details.");
      if (mounted) {
        setState(() {
          _areDetailsLoading = false;
        });
      }
      return;
    }

    try {
      // --- STEP 1: Call the ApiService to get the full product data ---
      // This single API call gets everything we need.
      final Map<String, dynamic> fullProductData = await _apiService.fetchProductDetailsBySku(sku.toString());

      // --- STEP 2: Directly access the data from the returned map ---
      // No need to parse 'custom_attributes'. The fields are at the top level.
      // We use '??' to provide safe fallback values.
      final String fullDesc = fullProductData['description']?[0] ?? widget.product['short_desc'] ?? 'No description available.';

      // Our PHP code creates a clean 'delivery_time' key for us.
      final String deliveryTime = fullProductData['delivery_time'] ?? 'Delivery time not specified.';

      // Our PHP code creates a clean 'processed_size_options' list for us.
      final List<dynamic> sizeOptions = fullProductData['processed_size_options'] ?? [];

      // --- STEP 3: Update the UI state with the new, complete data ---
      if (mounted) {
        setState(() {
          _fetchedProductDesc = fullDesc;
          _fetchedDeliveryTime = deliveryTime;

          // The data is already processed, so we can use it directly.
          // Let's assume you have a _sizeList to hold the size labels for your UI.
          _sizeList = sizeOptions.map((size) => size['label'].toString()).toList();

          _areDetailsLoading = false; // We are done loading.
        });
      }
    } catch (e) {
      print("Error fetching full product details for SKU $sku: $e");
      if (mounted) {
        setState(() {
          // You might want to show an error message in the UI here.
          _errorMessage = "Could not load product details. Please try again later.";
          _areDetailsLoading = false; // Stop the loading indicator.
        });
      }
    }
  }




  void _parseAndSetSizes() {
    final rawSizes = widget.product['size_name'];
    print('Raw sizes from API: $rawSizes (Type: ${rawSizes.runtimeType})');

    List<String> parsedSizes = [];

    if (rawSizes != null) {
      if (rawSizes is List && rawSizes.isNotEmpty) {
        parsedSizes = List<String>.from(rawSizes);
      } else if (rawSizes is String && rawSizes.isNotEmpty) {
        parsedSizes = rawSizes.split(',').map((s)=> s.trim()).toList();
      }
    }

    Map<String, String> finalSizeOptions = {};

    if (parsedSizes.isEmpty) {
      print("No valid sizes found, using default fallback.");
      finalSizeOptions = {"S": "Small", "M": "Medium", "L": "Large"};
    } else {
      for (var size in parsedSizes) {
        final apiValue = size.toLowerCase(); // This line stays the same
        String displayValue;
        String fullApiName;

        // The cases now correctly match the lowercase `apiValue`
        switch (apiValue) {
          case "xxsmall":   displayValue = "XXS";    fullApiName = "Xxsmall";   break;
          case "xsmall":    displayValue = "XS";     fullApiName = "Xsmall";    break;
          case "small":     displayValue = "S";      fullApiName = "Small";     break;
          case "medium":    displayValue = "M";      fullApiName = "Medium";    break;
          case "large":     displayValue = "L";      fullApiName = "Large";     break;
          case "xlarge":    displayValue = "XL";     fullApiName = "XLarge";    break;
          case "xxlarge":   displayValue = "XXL";    fullApiName = "XXLarge";   break;
          case "3xlarge":   displayValue = "3XL";    fullApiName = "3XLarge";   break;
          case "4xlarge":   displayValue = "4XL";    fullApiName = "4XLarge";   break;
          case "5xlarge":   displayValue = "5XL";    fullApiName = "5XLarge";   break;
          case "6xlarge":   displayValue = "6XL";    fullApiName = "6XLarge";   break;

        // ✅ FIX: Changed all "Years" cases to be lowercase
          case "0-3 months":   displayValue = "0-3 M";    fullApiName = "0-3 Months";   break;
          case "0-6 months":   displayValue = "0-6 M";    fullApiName = "0-6 Months";   break;
          case "3-6 months":   displayValue = "3-6 M";    fullApiName = "3-6 Months";   break;
          case "6-9 months":   displayValue = "6-9 M";    fullApiName = "6-9 Months";   break;
          case "6-12 months":   displayValue = "6-12 M";    fullApiName = "6-12 Months";   break;
          case "9-12 months":  displayValue = "9-12 M";    fullApiName ="9-12 Months";   break;
          case "1 month-1 year":  displayValue = "1 M-1 Y"; fullApiName ="1 Month-1 Year";   break;

          case "1-2 years":   displayValue = "1-2 Y";    fullApiName = "1-2 Years";   break;
          case "2-3 years":   displayValue = "2-3 Y";    fullApiName = "2-3 Years";   break;
          case "3-4 years":   displayValue = "3-4 Y";    fullApiName = "3-4 Years";   break;
          case "4-5 years":   displayValue = "4-5 Y";    fullApiName = "4-5 Years";   break;
          case "5-6 years":   displayValue = "5-6 Y";    fullApiName = "5-6 Years";   break;
          case "6-7 years":   displayValue = "6-7 Y";    fullApiName = "6-7 Years";   break;
          case "7-8 years":   displayValue = "7-8 Y";    fullApiName = "7-8 Years";   break;
          case "8-9 years":   displayValue = "8-9 Y";    fullApiName = "8-9 Years";   break;
          case "9-10 years":  displayValue = "9-10 Y";   fullApiName = "9-10 Years";  break;
          case "10-11 years": displayValue = "10-11 Y";  fullApiName = "10-11 Years"; break;
          case "11-12 years": displayValue = "11-12 Y";  fullApiName = "11-12 Years"; break;
          case "12-13 years": displayValue = "12-13 Y";  fullApiName = "12-13 Years"; break;
          case "13-14 years": displayValue = "13-14 Y";  fullApiName = "13-14 Years"; break;
          case "14-15 years": displayValue = "14-15 Y";  fullApiName = "14-15 Years"; break;
          case "15-16 years": displayValue = "15-16 Y";  fullApiName = "15-16 Years"; break;
          case "12-13 years": displayValue = "12-13 Y";  fullApiName = "12-13 Years"; break;
          case "custom made": displayValue = "CM"; fullApiName = "Custom Made"; break;
          case "free size": displayValue = "FS"; fullApiName = "Free Size"; break;


          case "euro size 31": displayValue = "EU 31"; fullApiName = "Euro Size 31"; break;
          case "euro size 32": displayValue = "EU 32"; fullApiName = "Euro Size 32"; break;
          case "euro size 33": displayValue = "EU 33"; fullApiName = "Euro Size 33"; break;
          case "euro size 34": displayValue = "EU 34"; fullApiName = "Euro Size 34"; break;


          case "euro size 35": displayValue = "EU 35"; fullApiName = "Euro Size 35"; break;
          case "euro size 36": displayValue = "EU 36"; fullApiName = "Euro Size 36"; break;
          case "euro size 37": displayValue = "EU 37"; fullApiName = "Euro Size 37"; break;
          case "euro size 38": displayValue = "EU 38"; fullApiName = "Euro Size 38"; break;
          case "euro size 39": displayValue = "EU 39"; fullApiName = "Euro Size 39"; break;
          case "euro size 40": displayValue = "EU 40"; fullApiName = "Euro Size 40"; break;
          case "euro size 41": displayValue = "EU 41"; fullApiName = "Euro Size 41"; break;
          case "euro size 42": displayValue = "EU 42"; fullApiName = "Euro Size 42"; break;
          case "euro size 43": displayValue = "EU 43"; fullApiName = "Euro Size 43"; break;
          case "euro size 44": displayValue = "EU 44"; fullApiName = "Euro Size 44"; break;
          case "euro size 45": displayValue = "EU 45"; fullApiName = "Euro Size 45"; break;
          case "euro size 46": displayValue = "EU 46"; fullApiName = "Euro Size 46"; break;
          case "euro size 47": displayValue = "EU 47"; fullApiName = "Euro Size 47"; break;
          case "euro size 48": displayValue = "EU 48"; fullApiName = "Euro Size 48"; break;
          case "euro size 49": displayValue = "EU 49"; fullApiName = "Euro Size 49"; break;
          case "euro size 50": displayValue = "EU 50"; fullApiName = "Euro Size 50"; break;

          default:
            displayValue = size.toUpperCase();
            fullApiName = size;
            break;

        }
        finalSizeOptions[displayValue] = fullApiName;
      }
    }

    // This part is outside the loop
    sizeOptions = finalSizeOptions;
    print("Final processed size options (Display -> API): $sizeOptions");
  }

  // void initState() {
  //   super.initState();
  //   _fetchCartQuantity();
  //   _pageController = PageController();
  //
  //   final rawSizes = widget.product['size_name'];
  //   print('Raw sizes from API: $rawSizes');
  //
  //   if (rawSizes != null && rawSizes is List && rawSizes.isNotEmpty) {
  //     sizes = List<String>.from(rawSizes).map((size) {
  //       switch (size.toLowerCase()) {
  //         case "xxsmall": return "Xxsmall";
  //         case "xsmall": return "Xsmall";
  //         case "small": return "Small";
  //         case "medium": return "Medium";
  //         case "large": return "Large";
  //         case "xlarge": return "XLarge";
  //         case "xxlarge": return "XXLarge";
  //         case "3xlarge": return "3XLarge";
  //         case "4xlarge": return "4XLarge";
  //         case "5xlarge": return "5XLarge";
  //         case "6xlarge": return "6XLarge";
  //         case "custom made": return "Custom Made";
  //         default: return size.toUpperCase(); // fallback
  //       }
  //     }).toList();
  //   } else {
  //     sizes = ["S", "M", "L"]; // fallback only if no data
  //   }
  //
  //   _loadUserNames();
  // }



  Future<void> _loadUserNames() async {
    final fName = await UserPreferences.getFirstName();
    final lName = await UserPreferences.getLastName();
    final  id = await UserPreferences.getCustomerId();

    print("cust>>$customer_id");

    setState(() {
      firstName = fName;
      lastName = lName;
      customer_id = id ?? 0;
    });

    print("cust====$customer_id");
  }

  // In your _ProductDetailNewInDetailScreenState class

  // In your _ProductDetailNewInDetailScreenState class

  // In _ProductDetailNewInDetailScreenState

// This is the new logic for adding to wishlist.
  // In _ProductDetailNewInDetailScreenState

  // In _ProductDetailNewInDetailScreenState

  // Future<void> _onAddToWishlistPressed() async {
  //   if (selectedSizeApiValue.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a size to add to wishlist.')));
  //     return;
  //   }
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null || customerToken.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to use the wishlist.')));
  //     return;
  //   }
  //
  //   setState(() { _isAddingToWishlist = true; });
  //
  //   try {
  //     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //     final adminTokenResponse = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/integration/admin/token'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'username': 'mahesh', 'password': 'mahesh@123'}),
  //     );
  //     if (adminTokenResponse.statusCode != 200) throw Exception('Failed to get admin token.');
  //     final adminToken = json.decode(adminTokenResponse.body);
  //
  //     final configurableSku = widget.product['prod_sku'];
  //     final childrenResponse = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$configurableSku/children'),
  //       headers: {'Authorization': 'Bearer $adminToken'},
  //     );
  //     if (childrenResponse.statusCode != 200) throw Exception('Failed to get product variants.');
  //
  //     final List<dynamic> children = json.decode(childrenResponse.body);
  //     final matchedChild = children.firstWhere(
  //           (child) => child['sku'].toString().toLowerCase().endsWith(selectedSizeApiValue.toLowerCase()),
  //       orElse: () => null,
  //     );
  //     if (matchedChild == null) throw Exception('Variant for size $selectedSizeApiValue not found.');
  //
  //     final String simpleSku = matchedChild['sku'];
  //     final productId = widget.product['prod_en_id']?.toString();
  //     if (productId == null) throw Exception('Product ID (prod_en_id) is missing.');
  //
  //     final existingMapString = prefs.getString('wishlist_variant_skus') ?? '{}';
  //     final Map<String, dynamic> skuMap = json.decode(existingMapString);
  //     skuMap[productId] = {'sku': simpleSku, 'size': selectedSizeDisplayValue};
  //     await prefs.setString('wishlist_variant_skus', json.encode(skuMap));
  //     print('[PDP SAVE] Saved to Prefs -> Key: $productId, Value: ${skuMap[productId]}');
  //
  //     final success = await _wishlistApiService.addToWishlist(int.parse(productId));
  //     if (success && mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added to wishlist!')));
  //       Navigator.push(context, MaterialPageRoute(builder: (context) => WishlistScreen1()));
  //     }
  //   } catch (e) {
  //     if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
  //   } finally {
  //     if (mounted) setState(() { _isAddingToWishlist = false; });
  //   }
  // }

  Future<void> _onAddToWishlistPressed() async {
    if (selectedSizeApiValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size to add to wishlist.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    if (customerToken == null || customerToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to use the wishlist.')),
      );
      return;
    }

    setState(() {
      _isAddingToWishlist = true;
    });

    try {
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      // 1. Get admin token
      final adminTokenResponse = await ioClient.post(
        Uri.parse('https://aashniandco.com/rest/V1/integration/admin/token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': 'mahesh', 'password': 'mahesh@123'}),
      );
      if (adminTokenResponse.statusCode != 200) {
        throw Exception('Failed to get admin token.');
      }
      final adminToken = json.decode(adminTokenResponse.body);

      // 2. Get configurable children
      final configurableSku = widget.product['prod_sku'];
      final childrenResponse = await ioClient.get(
        Uri.parse('https://aashniandco.com/rest/V1/configurable-products/$configurableSku/children'),
        headers: {'Authorization': 'Bearer $adminToken'},
      );
      if (childrenResponse.statusCode != 200) {
        throw Exception('Failed to get product variants.');
      }

      final List<dynamic> children = json.decode(childrenResponse.body);
      final matchedChild = children.firstWhere(
            (child) => child['sku']
            .toString()
            .toLowerCase()
            .endsWith(selectedSizeApiValue.toLowerCase()),
        orElse: () => null,
      );

      if (matchedChild == null) {
        throw Exception('Variant for size $selectedSizeApiValue not found.');
      }

      final String simpleSku = matchedChild['sku'];
      final productId = widget.product['prod_en_id']?.toString();
      if (productId == null) {
        throw Exception('Product ID (prod_en_id) is missing.');
      }

      // 3. Save variant mapping to prefs
      final existingMapString = prefs.getString('wishlist_variant_skus') ?? '{}';
      final Map<String, dynamic> skuMap = json.decode(existingMapString);
      skuMap[productId] = {
        'sku': simpleSku,
        'size': selectedSizeDisplayValue,
      };
      await prefs.setString('wishlist_variant_skus', json.encode(skuMap));
      print('[PDP SAVE] Saved to Prefs -> Key: $productId, Value: ${skuMap[productId]}');

      // 4. Add to wishlist (only now)
      final success = await _wishlistApiService.addToWishlist(int.parse(productId));

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added to wishlist!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WishlistScreen1()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToWishlist = false;
        });
      }
    }
  }


  //19/9/2025
  Future<void> onAddToCartPressed() async {
    if (selectedSizeApiValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a size')));
      return;
    }

    HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerToken = prefs.getString('user_token');
      final isGuest = customerToken == null || customerToken.isEmpty;

      final adminTokenResponse = await ioClient.post(
        Uri.parse('https://aashniandco.com/rest/V1/integration/admin/token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': 'mahesh', 'password': 'mahesh@123'}),
      );
      if (adminTokenResponse.statusCode != 200) throw Exception('Failed to get admin token.');
      final adminToken = json.decode(adminTokenResponse.body);

      final sku = widget.product['prod_sku'];
      final childrenResponse = await ioClient.get(
        Uri.parse('https://aashniandco.com/rest/V1/configurable-products/$sku/children'),
        headers: {'Authorization': 'Bearer $adminToken'},
      );
      if (childrenResponse.statusCode != 200) throw Exception('Failed to get product variants.');

      final List<dynamic> children = json.decode(childrenResponse.body);
      final matchedChild = children.firstWhere(
            (child) => child['sku'].toString().toLowerCase().endsWith(selectedSizeApiValue.toLowerCase()),
        orElse: () => null,
      );
      if (matchedChild == null) throw Exception('Size $selectedSizeApiValue not available.');

      final matchedSku = matchedChild['sku'];
      String? quoteId;
      if (isGuest) {
        quoteId = prefs.getString('guest_quote_id');
        if (quoteId == null) {
          final createGuestCartResponse = await ioClient.post(Uri.parse('https://aashniandco.com/rest/V1/guest-carts'));
          if (createGuestCartResponse.statusCode == 200) {
            quoteId = createGuestCartResponse.body.replaceAll('"', '');
            await prefs.setString('guest_quote_id', quoteId);
          } else { throw Exception('Guest cart creation failed'); }
        }
      } else {
        try {
          final cartResponse = await ioClient.get(Uri.parse('https://aashniandco.com/rest/V1/carts/mine'), headers: {'Authorization': 'Bearer $customerToken'});
          if (cartResponse.statusCode == 200) {
            quoteId = json.decode(cartResponse.body)['id'].toString();
          } else { throw Exception('No cart found'); }
        } catch (_) {
          final createCartResponse = await ioClient.post(Uri.parse('https://aashniandco.com/rest/V1/carts/mine'), headers: {'Authorization': 'Bearer $customerToken'});
          if (createCartResponse.statusCode == 200) {
            quoteId = json.decode(createCartResponse.body).toString();
          } else { throw Exception('Error creating cart'); }
        }
      }

      if (quoteId == null) throw Exception('Could not get cart ID.');

      final addToCartUrl = isGuest ? 'https://aashniandco.com/rest/V1/guest-carts/$quoteId/items' : 'https://aashniandco.com/rest/V1/carts/mine/items';
      final headers = {'Content-Type': 'application/json', if (!isGuest) 'Authorization': 'Bearer $customerToken'};
      final addToCartResponse = await ioClient.post(
        Uri.parse(addToCartUrl),
        headers: headers,
        body: json.encode({"cartItem": {"sku": matchedSku, "qty": 1, "quote_id": quoteId}}),
      );

      if (addToCartResponse.statusCode == 200) {
        _fetchCartQuantity();
        final selectedProduct = {...widget.product, 'selectedSize': selectedSizeDisplayValue, 'childSku': matchedSku};
        await saveProductToPrefs(selectedProduct);
        if (mounted) _showAddedToCartDialog();
      } else {
        throw Exception('Failed to add product to cart: ${addToCartResponse.body}');
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: ${e.toString()}')));
    }
  }


  // Future<void> onAddToCartPressed() async {
  //   if (selectedSizeApiValue.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a size')),
  //     );
  //     return;
  //   }
  //
  //   HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final customerToken = prefs.getString('user_token');
  //     final isGuest = customerToken == null || customerToken.isEmpty;
  //
  //     // 🔑 Get Admin Token
  //     final adminTokenResponse = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/integration/admin/token'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'username': 'mahesh', 'password': 'mahesh@123'}),
  //     );
  //     if (adminTokenResponse.statusCode != 200) throw Exception('Failed to get admin token.');
  //     final adminToken = json.decode(adminTokenResponse.body);
  //
  //     // 🔑 Find child SKU
  //     final sku = widget.product['prod_sku'];
  //     final childrenResponse = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$sku/children'),
  //       headers: {'Authorization': 'Bearer $adminToken'},
  //     );
  //     if (childrenResponse.statusCode != 200) throw Exception('Failed to get product variants.');
  //
  //     final List<dynamic> children = json.decode(childrenResponse.body);
  //     final matchedChild = children.firstWhere(
  //           (child) => child['sku'].toString().toLowerCase().endsWith(selectedSizeApiValue.toLowerCase()),
  //       orElse: () => null,
  //     );
  //     if (matchedChild == null) throw Exception('Size $selectedSizeApiValue not available.');
  //
  //     final matchedSku = matchedChild['sku'];
  //
  //     // 🔑 Get or create quoteId
  //     String? quoteId;
  //     if (isGuest) {
  //       quoteId = prefs.getString('guest_quote_id');
  //       if (quoteId == null) {
  //         final createGuestCartResponse = await ioClient.post(
  //           Uri.parse('https://stage.aashniandco.com/rest/V1/guest-carts'),
  //         );
  //         if (createGuestCartResponse.statusCode == 200) {
  //           quoteId = createGuestCartResponse.body.replaceAll('"', '');
  //           await prefs.setString('guest_quote_id', quoteId);
  //         } else {
  //           throw Exception('Guest cart creation failed');
  //         }
  //       }
  //
  //       // 🆕 Fetch real frontend cookies for WebView
  //       try {
  //         final frontendUrl = Uri.parse('https://stage.aashniandco.com/checkout/');
  //         final frontendReq = await httpClient.getUrl(frontendUrl);
  //
  //         // simulate a real browser
  //         frontendReq.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
  //             '(KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36');
  //
  //         final frontendResp = await frontendReq.close();
  //
  //         print("⬅️ Frontend Response status: ${frontendResp.statusCode}");
  //         frontendResp.headers.forEach((name, values) {
  //           print("   $name: $values");
  //         });
  //
  //         List<Map<String, dynamic>> cookiesList = [];
  //         for (var cookie in frontendResp.cookies) {
  //           cookiesList.add({
  //             "name": cookie.name,
  //             "value": cookie.value,
  //             "domain": cookie.domain ?? "stage.aashniandco.com",
  //             "path": cookie.path ?? "/",
  //             "secure": cookie.secure,
  //             "httponly": cookie.httpOnly,
  //           });
  //           print("🍪 Cookie from frontend: ${cookie.name} = ${cookie.value}");
  //         }
  //
  //         // Save cookies for WebView
  //         await prefs.setString("guest_cart_cookies", json.encode(cookiesList));
  //       } catch (e) {
  //         debugPrint("⚠️ Failed to fetch frontend cookies: $e");
  //       }
  //     } else {
  //       try {
  //         final cartResponse = await ioClient.get(
  //           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //           headers: {'Authorization': 'Bearer $customerToken'},
  //         );
  //         if (cartResponse.statusCode == 200) {
  //           quoteId = json.decode(cartResponse.body)['id'].toString();
  //         } else {
  //           throw Exception('No cart found');
  //         }
  //       } catch (_) {
  //         final createCartResponse = await ioClient.post(
  //           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //           headers: {'Authorization': 'Bearer $customerToken'},
  //         );
  //         if (createCartResponse.statusCode == 200) {
  //           quoteId = json.decode(createCartResponse.body).toString();
  //         } else {
  //           throw Exception('Error creating cart');
  //         }
  //       }
  //     }
  //
  //     if (quoteId == null) throw Exception('Could not get cart ID.');
  //
  //     // 🔑 Add to cart
  //     final addToCartUrl = isGuest
  //         ? 'https://stage.aashniandco.com/rest/V1/guest-carts/$quoteId/items'
  //         : 'https://stage.aashniandco.com/rest/V1/carts/mine/items';
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       if (!isGuest) 'Authorization': 'Bearer $customerToken'
  //     };
  //
  //     final addToCartResponse = await ioClient.post(
  //       Uri.parse(addToCartUrl),
  //       headers: headers,
  //       body: json.encode({
  //         "cartItem": {"sku": matchedSku, "qty": 1, "quote_id": quoteId}
  //       }),
  //     );
  //
  //     if (addToCartResponse.statusCode == 200) {
  //       _fetchCartQuantity();
  //       final selectedProduct = {
  //         ...widget.product,
  //         'selectedSize': selectedSizeDisplayValue,
  //         'childSku': matchedSku
  //       };
  //       await saveProductToPrefs(selectedProduct);
  //       if (mounted) _showAddedToCartDialog();
  //     } else {
  //       throw Exception('Failed to add product to cart: ${addToCartResponse.body}');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('An error occurred: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }


  // Future<void> onAddToCartPressed() async {
  //   if (selectedSizeApiValue.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a size')),
  //     );
  //     return;
  //   }
  //
  //   HttpClient httpClient = HttpClient()
  //     ..badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final customerToken = prefs.getString('user_token');
  //     final isGuest = customerToken == null || customerToken.isEmpty;
  //
  //     // 🔑 Get Admin Token
  //     final adminTokenResponse = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/integration/admin/token'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'username': 'mahesh', 'password': 'mahesh@123'}),
  //     );
  //     if (adminTokenResponse.statusCode != 200) {
  //       throw Exception('Failed to get admin token.');
  //     }
  //     final adminToken = json.decode(adminTokenResponse.body);
  //
  //     // 🔑 Find child SKU
  //     final sku = widget.product['prod_sku'];
  //     final childrenResponse = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$sku/children'),
  //       headers: {'Authorization': 'Bearer $adminToken'},
  //     );
  //     if (childrenResponse.statusCode != 200) {
  //       throw Exception('Failed to get product variants.');
  //     }
  //
  //     final List<dynamic> children = json.decode(childrenResponse.body);
  //     final matchedChild = children.firstWhere(
  //           (child) => child['sku']
  //           .toString()
  //           .toLowerCase()
  //           .endsWith(selectedSizeApiValue.toLowerCase()),
  //       orElse: () => null,
  //     );
  //     if (matchedChild == null) {
  //       throw Exception('Size $selectedSizeApiValue not available.');
  //     }
  //
  //     final matchedSku = matchedChild['sku'];
  //
  //     // 🔑 Get or create quoteId
  //     String? quoteId;
  //     if (isGuest) {
  //       quoteId = prefs.getString('guest_quote_id');
  //       if (quoteId == null) {
  //         final createGuestCartResponse = await ioClient.post(
  //           Uri.parse('https://stage.aashniandco.com/rest/V1/guest-carts'),
  //         );
  //         if (createGuestCartResponse.statusCode == 200) {
  //           quoteId = createGuestCartResponse.body.replaceAll('"', '');
  //           await prefs.setString('guest_quote_id', quoteId);
  //         } else {
  //           throw Exception('Guest cart creation failed');
  //         }
  //       }
  //
  //       // 🆕 Fetch frontend cookies properly
  //       try {
  //         final frontendUrl = Uri.parse('https://stage.aashniandco.com/checkout/');
  //         final frontendReq = await httpClient.getUrl(frontendUrl);
  //
  //         frontendReq.headers.set(
  //           'User-Agent',
  //           'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
  //               '(KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
  //         );
  //
  //         final frontendResp = await frontendReq.close();
  //         print("⬅️ Frontend Response status: ${frontendResp.statusCode}");
  //
  //         List<Map<String, dynamic>> cookiesList = [];
  //
  //         // ✅ Capture cookies via `frontendResp.cookies`
  //         for (var cookie in frontendResp.cookies) {
  //           cookiesList.add({
  //             "name": cookie.name,
  //             "value": cookie.value,
  //             "domain": cookie.domain ?? "stage.aashniandco.com",
  //             "path": cookie.path ?? "/",
  //             "secure": cookie.secure,
  //             "httponly": cookie.httpOnly,
  //           });
  //           print("🍪 Cookie (direct): ${cookie.name} = ${cookie.value}");
  //         }
  //
  //         // ✅ Also capture cookies from Set-Cookie headers
  //         frontendResp.headers.forEach((name, values) {
  //           if (name.toLowerCase() == 'set-cookie') {
  //             for (var cookieStr in values) {
  //               final parts = cookieStr.split(';');
  //               final nameValue = parts.first.split('=');
  //               if (nameValue.length == 2) {
  //                 final cName = nameValue[0].trim();
  //                 final cValue = nameValue[1].trim();
  //                 if (!cookiesList.any((c) => c['name'] == cName)) {
  //                   cookiesList.add({
  //                     "name": cName,
  //                     "value": cValue,
  //                     "domain": "stage.aashniandco.com",
  //                     "path": "/",
  //                     "secure": cookieStr.contains("Secure"),
  //                     "httponly": cookieStr.toLowerCase().contains("httponly"),
  //                   });
  //                 }
  //                 print("🍪 Cookie (Set-Cookie): $cName = $cValue");
  //               }
  //             }
  //           }
  //         });
  //
  //         // Save cookies for WebView
  //         await prefs.setString("guest_cart_cookies", json.encode(cookiesList));
  //         print("✅ Guest cookies saved to SharedPreferences");
  //       } catch (e) {
  //         debugPrint("⚠️ Failed to fetch frontend cookies: $e");
  //       }
  //     } else {
  //       // Authenticated user flow...
  //       try {
  //         final cartResponse = await ioClient.get(
  //           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //           headers: {'Authorization': 'Bearer $customerToken'},
  //         );
  //         if (cartResponse.statusCode == 200) {
  //           quoteId = json.decode(cartResponse.body)['id'].toString();
  //         } else {
  //           throw Exception('No cart found');
  //         }
  //       } catch (_) {
  //         final createCartResponse = await ioClient.post(
  //           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //           headers: {'Authorization': 'Bearer $customerToken'},
  //         );
  //         if (createCartResponse.statusCode == 200) {
  //           quoteId = json.decode(createCartResponse.body).toString();
  //         } else {
  //           throw Exception('Error creating cart');
  //         }
  //       }
  //     }
  //
  //     if (quoteId == null) throw Exception('Could not get cart ID.');
  //
  //     // 🔑 Add to cart
  //     final addToCartUrl = isGuest
  //         ? 'https://stage.aashniandco.com/rest/V1/guest-carts/$quoteId/items'
  //         : 'https://stage.aashniandco.com/rest/V1/carts/mine/items';
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       if (!isGuest) 'Authorization': 'Bearer $customerToken'
  //     };
  //
  //     final addToCartResponse = await ioClient.post(
  //       Uri.parse(addToCartUrl),
  //       headers: headers,
  //       body: json.encode({
  //         "cartItem": {"sku": matchedSku, "qty": 1, "quote_id": quoteId}
  //       }),
  //     );
  //
  //     if (addToCartResponse.statusCode == 200) {
  //       _fetchCartQuantity();
  //       final selectedProduct = {
  //         ...widget.product,
  //         'selectedSize': selectedSizeDisplayValue,
  //         'childSku': matchedSku
  //       };
  //       await saveProductToPrefs(selectedProduct);
  //       if (mounted) _showAddedToCartDialog();
  //     } else {
  //       throw Exception(
  //           'Failed to add product to cart: ${addToCartResponse.body}');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('An error occurred: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }

  // Future<void> onAddToCartPressed() async {
  //   if (selectedSizeApiValue.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a size')),
  //     );
  //     return;
  //   }
  //
  //   final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //   final ioClient = IOClient(httpClient);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final customerToken = prefs.getString('user_token');
  //     final isGuest = customerToken == null || customerToken.isEmpty;
  //
  //     // 🔑 Get Admin Token for configurable children only
  //     final adminTokenResponse = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/integration/admin/token'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'username': 'mahesh', 'password': 'mahesh@123'}),
  //     );
  //     if (adminTokenResponse.statusCode != 200) {
  //       throw Exception('Failed to get admin token.');
  //     }
  //     final adminToken = json.decode(adminTokenResponse.body);
  //
  //     // 🔑 Get child SKU for selected size
  //     final sku = widget.product['prod_sku'];
  //     final childrenResponse = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$sku/children'),
  //       headers: {'Authorization': 'Bearer $adminToken'},
  //     );
  //     if (childrenResponse.statusCode != 200) {
  //       throw Exception('Failed to fetch product variants.');
  //     }
  //
  //     final List<dynamic> children = json.decode(childrenResponse.body);
  //     final matchedChild = children.firstWhere(
  //           (child) => child['sku'].toString().toLowerCase().endsWith(selectedSizeApiValue.toLowerCase()),
  //       orElse: () => null,
  //     );
  //     if (matchedChild == null) {
  //       throw Exception('Selected size not available.');
  //     }
  //     final matchedSku = matchedChild['sku'];
  //
  //     // 🔑 Get or create quoteId
  //     String? quoteId;
  //
  //     if (isGuest) {
  //       // Always create a new guest cart to ensure Magento sets `customer_is_guest: true`
  //       final createGuestCartResponse = await ioClient.post(
  //         Uri.parse('https://stage.aashniandco.com/rest/V1/guest-carts'),
  //       );
  //       if (createGuestCartResponse.statusCode != 200) {
  //         throw Exception('Failed to create guest cart');
  //       }
  //       quoteId = createGuestCartResponse.body.replaceAll('"', '');
  //       await prefs.setString('guest_quote_id', quoteId);
  //
  //       // Optional: Fetch frontend cookies for WebView
  //       try {
  //         final frontendUrl = Uri.parse('https://stage.aashniandco.com/checkout/');
  //         final frontendReq = await httpClient.getUrl(frontendUrl);
  //         frontendReq.headers.set(
  //           'User-Agent',
  //           'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
  //         );
  //         final frontendResp = await frontendReq.close();
  //
  //         List<Map<String, dynamic>> cookiesList = [];
  //         for (var cookie in frontendResp.cookies) {
  //           cookiesList.add({
  //             "name": cookie.name,
  //             "value": cookie.value,
  //             "domain": cookie.domain ?? "stage.aashniandco.com",
  //             "path": cookie.path ?? "/",
  //             "secure": cookie.secure,
  //             "httponly": cookie.httpOnly,
  //           });
  //         }
  //         await prefs.setString("guest_cart_cookies", json.encode(cookiesList));
  //       } catch (_) {
  //         debugPrint("⚠️ Failed to fetch frontend cookies");
  //       }
  //     } else {
  //       // Logged-in user: get cart or create if not exists
  //       try {
  //         final cartResponse = await ioClient.get(
  //           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //           headers: {'Authorization': 'Bearer $customerToken'},
  //         );
  //         quoteId = cartResponse.statusCode == 200
  //             ? json.decode(cartResponse.body)['id'].toString()
  //             : null;
  //
  //         if (quoteId == null) {
  //           final createCartResponse = await ioClient.post(
  //             Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //             headers: {'Authorization': 'Bearer $customerToken'},
  //           );
  //           if (createCartResponse.statusCode != 200) {
  //             throw Exception('Failed to create user cart');
  //           }
  //           quoteId = json.decode(createCartResponse.body).toString();
  //         }
  //       } catch (e) {
  //         throw Exception('Error fetching user cart: $e');
  //       }
  //     }
  //
  //     if (quoteId == null) throw Exception('Could not get cart ID.');
  //
  //     // 🔑 Add to cart
  //     final addToCartUrl = isGuest
  //         ? 'https://stage.aashniandco.com/rest/V1/guest-carts/$quoteId/items'
  //         : 'https://stage.aashniandco.com/rest/V1/carts/mine/items';
  //
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       if (!isGuest) 'Authorization': 'Bearer $customerToken',
  //     };
  //
  //     final addToCartResponse = await ioClient.post(
  //       Uri.parse(addToCartUrl),
  //       headers: headers,
  //       body: json.encode({
  //         "cartItem": {"sku": matchedSku, "qty": 1, "quote_id": quoteId}
  //       }),
  //     );
  //
  //     if (addToCartResponse.statusCode == 200) {
  //       _fetchCartQuantity(); // update cart icon
  //       final selectedProduct = {
  //         ...widget.product,
  //         'selectedSize': selectedSizeDisplayValue,
  //         'childSku': matchedSku
  //       };
  //       await saveProductToPrefs(selectedProduct);
  //       if (mounted) _showAddedToCartDialog();
  //     } else {
  //       throw Exception('Failed to add to cart: ${addToCartResponse.body}');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }


  Future<bool> verifyGuestCart(String quoteId) async {
    final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    final ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.get(
        Uri.parse('https://aashniandco.com/rest/V1/guest-carts/$quoteId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isGuest = data['customer_is_guest'] ?? false;
        debugPrint("🔍 Guest cart verification: customer_is_guest = $isGuest");
        return isGuest;
      } else {
        debugPrint("⚠️ Failed to verify guest cart: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Error verifying guest cart: $e");
      return false;
    }
  }
  // Future<void> onAddToCartPressed() async {
  //   if (selectedSizeApiValue.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a size')),
  //     );
  //     return;
  //   }
  //
  //   final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //   final ioClient = IOClient(httpClient);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final customerToken = prefs.getString('user_token');
  //     final isGuest = customerToken == null || customerToken.isEmpty;
  //
  //     // 🔑 Get Admin Token (for configurable children only)
  //     final adminTokenResponse = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/integration/admin/token'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'username': 'mahesh', 'password': 'mahesh@123'}),
  //     );
  //     if (adminTokenResponse.statusCode != 200) {
  //       throw Exception('Failed to get admin token.');
  //     }
  //     final adminToken = json.decode(adminTokenResponse.body);
  //
  //     // 🔑 Get child SKU for selected size
  //     final sku = widget.product['prod_sku'];
  //     final childrenResponse = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$sku/children'),
  //       headers: {'Authorization': 'Bearer $adminToken'},
  //     );
  //     if (childrenResponse.statusCode != 200) {
  //       throw Exception('Failed to fetch product variants.');
  //     }
  //
  //     final List<dynamic> children = json.decode(childrenResponse.body);
  //     final matchedChild = children.firstWhere(
  //           (child) => child['sku'].toString().toLowerCase().endsWith(selectedSizeApiValue.toLowerCase()),
  //       orElse: () => null,
  //     );
  //     if (matchedChild == null) {
  //       throw Exception('Selected size not available.');
  //     }
  //     final matchedSku = matchedChild['sku'];
  //
  //     // 🔑 Get or create quoteId
  //     String? quoteId;
  //
  //     if (isGuest) {
  //       // Always create a new guest cart to ensure Magento sets customer_is_guest: true
  //       final createGuestCartResponse = await ioClient.post(
  //         Uri.parse('https://stage.aashniandco.com/rest/V1/guest-carts'),
  //       );
  //       if (createGuestCartResponse.statusCode != 200) {
  //         throw Exception('Failed to create guest cart');
  //       }
  //       quoteId = createGuestCartResponse.body.replaceAll('"', '');
  //       await prefs.setString('guest_quote_id', quoteId);
  //
  //       // 🔍 Verify guest cart
  //       // final isVerified = await verifyGuestCart(quoteId);
  //       // if (!isVerified) {
  //       //   throw Exception('Guest cart verification failed: customer_is_guest is false!');
  //       // }
  //
  //       // Optional: Fetch frontend cookies for WebView
  //       try {
  //         final frontendUrl = Uri.parse('https://stage.aashniandco.com/checkout/');
  //         final frontendReq = await httpClient.getUrl(frontendUrl);
  //         frontendReq.headers.set(
  //           'User-Agent',
  //           'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
  //         );
  //         final frontendResp = await frontendReq.close();
  //
  //         List<Map<String, dynamic>> cookiesList = [];
  //         for (var cookie in frontendResp.cookies) {
  //           cookiesList.add({
  //             "name": cookie.name,
  //             "value": cookie.value,
  //             "domain": cookie.domain ?? "stage.aashniandco.com",
  //             "path": cookie.path ?? "/",
  //             "secure": cookie.secure,
  //             "httponly": cookie.httpOnly,
  //           });
  //         }
  //         await prefs.setString("guest_cart_cookies", json.encode(cookiesList));
  //       } catch (_) {
  //         debugPrint("⚠️ Failed to fetch frontend cookies");
  //       }
  //     } else {
  //       // Logged-in user: get cart or create if not exists
  //       try {
  //         final cartResponse = await ioClient.get(
  //           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //           headers: {'Authorization': 'Bearer $customerToken'},
  //         );
  //         quoteId = cartResponse.statusCode == 200
  //             ? json.decode(cartResponse.body)['id'].toString()
  //             : null;
  //
  //         if (quoteId == null) {
  //           final createCartResponse = await ioClient.post(
  //             Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //             headers: {'Authorization': 'Bearer $customerToken'},
  //           );
  //           if (createCartResponse.statusCode != 200) {
  //             throw Exception('Failed to create user cart');
  //           }
  //           quoteId = json.decode(createCartResponse.body).toString();
  //         }
  //       } catch (e) {
  //         throw Exception('Error fetching user cart: $e');
  //       }
  //     }
  //
  //     if (quoteId == null) throw Exception('Could not get cart ID.');
  //
  //     // 🔑 Add to cart
  //     final addToCartUrl = isGuest
  //         ? 'https://stage.aashniandco.com/rest/V1/guest-carts/$quoteId/items'
  //         : 'https://stage.aashniandco.com/rest/V1/carts/mine/items';
  //
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       if (!isGuest) 'Authorization': 'Bearer $customerToken',
  //     };
  //
  //     final addToCartResponse = await ioClient.post(
  //       Uri.parse(addToCartUrl),
  //       headers: headers,
  //       body: json.encode({
  //         "cartItem": {"sku": matchedSku, "qty": 1, "quote_id": quoteId}
  //       }),
  //     );
  //
  //     if (addToCartResponse.statusCode == 200) {
  //       _fetchCartQuantity(); // update cart icon
  //       final selectedProduct = {
  //         ...widget.product,
  //         'selectedSize': selectedSizeDisplayValue,
  //         'childSku': matchedSku
  //       };
  //       await saveProductToPrefs(selectedProduct);
  //       if (mounted) _showAddedToCartDialog();
  //     } else {
  //       throw Exception('Failed to add to cart: ${addToCartResponse.body}');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }

  // Future<void> onAddToCartPressed() async {
  //   if (selectedSizeApiValue.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a size')),
  //     );
  //     return;
  //   }
  //
  //   final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //   final ioClient = IOClient(httpClient);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final customerToken = prefs.getString('user_token');
  //     final isGuest = customerToken == null || customerToken.isEmpty;
  //
  //     String? quoteId;
  //
  //     if (isGuest) {
  //       // 1️⃣ Create fresh guest cart
  //       final createGuestCartResp = await ioClient.post(
  //         Uri.parse('https://stage.aashniandco.com/rest/V1/guest-carts'),
  //         headers: {'Content-Type': 'application/json'},
  //       );
  //
  //       if (createGuestCartResp.statusCode != 200) {
  //         throw Exception('Failed to create guest cart');
  //       }
  //
  //       quoteId = createGuestCartResp.body.replaceAll('"', '');
  //       await prefs.setString('guest_quote_id', quoteId);
  //
  //       // Optional: fetch frontend cookies for WebView
  //       try {
  //         final frontendUrl = Uri.parse('https://stage.aashniandco.com/checkout/');
  //         final frontendReq = await httpClient.getUrl(frontendUrl);
  //         frontendReq.headers.set(
  //           'User-Agent',
  //           'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
  //         );
  //         final frontendResp = await frontendReq.close();
  //
  //         List<Map<String, dynamic>> cookiesList = [];
  //         for (var cookie in frontendResp.cookies) {
  //           cookiesList.add({
  //             "name": cookie.name,
  //             "value": cookie.value,
  //             "domain": cookie.domain ?? "stage.aashniandco.com",
  //             "path": cookie.path ?? "/",
  //             "secure": cookie.secure,
  //             "httponly": cookie.httpOnly,
  //           });
  //         }
  //         await prefs.setString("guest_cart_cookies", json.encode(cookiesList));
  //       } catch (_) {
  //         debugPrint("⚠️ Failed to fetch frontend cookies");
  //       }
  //     } else {
  //       // Logged-in user: get or create cart
  //       final cartResp = await ioClient.get(
  //         Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //         headers: {'Authorization': 'Bearer $customerToken'},
  //       );
  //
  //       if (cartResp.statusCode == 200) {
  //         quoteId = json.decode(cartResp.body)['id'].toString();
  //       } else {
  //         final createCartResp = await ioClient.post(
  //           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //           headers: {'Authorization': 'Bearer $customerToken'},
  //         );
  //         if (createCartResp.statusCode != 200) {
  //           throw Exception('Failed to create user cart');
  //         }
  //         quoteId = json.decode(createCartResp.body).toString();
  //       }
  //     }
  //
  //     if (quoteId == null) throw Exception('Could not get cart ID');
  //
  //     // 2️⃣ Fetch configurable children using admin token (read-only)
  //     final sku = widget.product['prod_sku'];
  //     final adminTokenResp = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/integration/admin/token'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'username': 'mahesh', 'password': 'mahesh@123'}),
  //     );
  //     if (adminTokenResp.statusCode != 200) throw Exception('Failed to get admin token');
  //     final adminToken = json.decode(adminTokenResp.body);
  //
  //     final childrenResp = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$sku/children'),
  //       headers: {'Authorization': 'Bearer $adminToken'},
  //     );
  //     if (childrenResp.statusCode != 200) throw Exception('Failed to fetch product variants');
  //
  //     final List<dynamic> children = json.decode(childrenResp.body);
  //     final matchedChild = children.firstWhere(
  //           (child) => child['sku'].toString().toLowerCase().endsWith(selectedSizeApiValue.toLowerCase()),
  //       orElse: () => null,
  //     );
  //
  //     if (matchedChild == null) throw Exception('Selected size not available');
  //     final matchedSku = matchedChild['sku'];
  //
  //     // 3️⃣ Add to cart
  //     final addToCartUrl = isGuest
  //         ? 'https://stage.aashniandco.com/rest/V1/guest-carts/$quoteId/items'
  //         : 'https://stage.aashniandco.com/rest/V1/carts/mine/items';
  //
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       if (!isGuest) 'Authorization': 'Bearer $customerToken',
  //     };
  //
  //     final addToCartResp = await ioClient.post(
  //       Uri.parse(addToCartUrl),
  //       headers: headers,
  //       body: json.encode({
  //         "cartItem": {"sku": matchedSku, "qty": 1, "quote_id": quoteId}
  //       }),
  //     );
  //
  //     if (addToCartResp.statusCode == 200) {
  //       _fetchCartQuantity();
  //       final selectedProduct = {
  //         ...widget.product,
  //         'selectedSize': selectedSizeDisplayValue,
  //         'childSku': matchedSku
  //       };
  //       await saveProductToPrefs(selectedProduct);
  //       if (mounted) _showAddedToCartDialog();
  //     } else {
  //       throw Exception('Failed to add to cart: ${addToCartResp.body}');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }

  // Future<void> onAddToCartPressed() async {
  //   if (selectedSizeApiValue.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a size')),
  //     );
  //     return;
  //   }
  //
  //   final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //   final ioClient = IOClient(httpClient);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final customerToken = prefs.getString('user_token');
  //     final isGuest = customerToken == null || customerToken.isEmpty;
  //
  //     // ✅ Step 1: Get or create a cart
  //     final quoteId = await _getOrCreateCart(ioClient, httpClient, prefs, customerToken);
  //
  //     if (quoteId == null) throw Exception("Failed to create/get cart ID");
  //
  //     // ✅ Step 2: Resolve child SKU for configurable product
  //     final sku = widget.product['prod_sku'];
  //     final matchedSku = await _getChildSku(ioClient, sku, selectedSizeApiValue);
  //
  //     if (matchedSku == null) throw Exception('Selected size not available');
  //
  //     // ✅ Step 3: Add to cart (guest or logged-in)
  //     final addToCartUrl = isGuest
  //         ? 'https://stage.aashniandco.com/rest/V1/guest-carts/$quoteId/items'
  //         : 'https://stage.aashniandco.com/rest/V1/carts/mine/items';
  //
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       if (!isGuest) 'Authorization': 'Bearer $customerToken',
  //     };
  //
  //     final addToCartResp = await ioClient.post(
  //       Uri.parse(addToCartUrl),
  //       headers: headers,
  //       body: json.encode({
  //         "cartItem": {"sku": matchedSku, "qty": 1, "quote_id": quoteId}
  //       }),
  //     );
  //
  //     if (addToCartResp.statusCode == 200) {
  //       _fetchCartQuantity();
  //       final selectedProduct = {
  //         ...widget.product,
  //         'selectedSize': selectedSizeDisplayValue,
  //         'childSku': matchedSku
  //       };
  //       await saveProductToPrefs(selectedProduct);
  //       if (mounted) _showAddedToCartDialog();
  //     } else {
  //       throw Exception('Failed to add to cart: ${addToCartResp.body}');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }
  //
  // /// 🔹 Get or create guest/user cart
  // Future<String?> _getOrCreateCart(
  //     IOClient ioClient,
  //     HttpClient httpClient,
  //     SharedPreferences prefs,
  //     String? customerToken,
  //     ) async {
  //   final isGuest = customerToken == null || customerToken.isEmpty;
  //
  //   if (isGuest) {
  //     final resp = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/guest-carts'),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //
  //     if (resp.statusCode == 200) {
  //       final quoteId = resp.body.replaceAll('"', '');
  //       await prefs.setString('guest_quote_id', quoteId);
  //
  //       // Fetch cookies (optional)
  //       try {
  //         final frontendUrl = Uri.parse('https://stage.aashniandco.com/checkout/');
  //         final frontendReq = await httpClient.getUrl(frontendUrl);
  //         frontendReq.headers.set(
  //           'User-Agent',
  //           'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
  //         );
  //         final frontendResp = await frontendReq.close();
  //
  //         List<Map<String, dynamic>> cookiesList = [];
  //         for (var cookie in frontendResp.cookies) {
  //           cookiesList.add({
  //             "name": cookie.name,
  //             "value": cookie.value,
  //             "domain": cookie.domain ?? "stage.aashniandco.com",
  //             "path": cookie.path ?? "/",
  //             "secure": cookie.secure,
  //             "httponly": cookie.httpOnly,
  //           });
  //         }
  //         await prefs.setString("guest_cart_cookies", json.encode(cookiesList));
  //       } catch (_) {
  //         debugPrint("⚠️ Failed to fetch frontend cookies");
  //       }
  //
  //       return quoteId;
  //     }
  //     return null;
  //   } else {
  //     // Try to get existing user cart
  //     final cartResp = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //       headers: {'Authorization': 'Bearer $customerToken'},
  //     );
  //
  //     if (cartResp.statusCode == 200) {
  //       return json.decode(cartResp.body)['id'].toString();
  //     }
  //
  //     // Otherwise create new cart
  //     final createCartResp = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //       headers: {'Authorization': 'Bearer $customerToken'},
  //     );
  //     if (createCartResp.statusCode == 200) {
  //       return json.decode(createCartResp.body).toString();
  //     }
  //     return null;
  //   }
  // }
  //
  // /// 🔹 Resolve correct child SKU for selected size
  // Future<String?> _getChildSku(IOClient ioClient, String parentSku, String selectedSizeApiValue) async {
  //   final adminTokenResp = await ioClient.post(
  //     Uri.parse('https://stage.aashniandco.com/rest/V1/integration/admin/token'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({'username': 'mahesh', 'password': 'mahesh@123'}),
  //   );
  //
  //   if (adminTokenResp.statusCode != 200) throw Exception('Failed to get admin token');
  //   final adminToken = json.decode(adminTokenResp.body);
  //
  //   final childrenResp = await ioClient.get(
  //     Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$parentSku/children'),
  //     headers: {'Authorization': 'Bearer $adminToken'},
  //   );
  //
  //   if (childrenResp.statusCode != 200) throw Exception('Failed to fetch product variants');
  //   final List<dynamic> children = json.decode(childrenResp.body);
  //
  //   final matchedChild = children.firstWhere(
  //         (child) => child['sku'].toString().toLowerCase().endsWith(selectedSizeApiValue.toLowerCase()),
  //     orElse: () => null,
  //   );
  //
  //   return matchedChild?['sku'];
  // }
  //


  Future<void> _fetchCartQuantity() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final isGuest = customerToken == null || customerToken.isEmpty;
    HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);
    try {
      String? cartId;
      String url;
      Map<String, String> headers = {};

      if (isGuest) {
        cartId = prefs.getString('guest_quote_id');
        if (cartId == null) { if (mounted) setState(() => cartQty = 0); return; }
        url = 'https://aashniandco.com/rest/V1/guest-carts/$cartId';
      } else {
        url = 'https://aashniandco.com/rest/V1/carts/mine';
        headers = {'Authorization': 'Bearer $customerToken', 'Content-Type': 'application/json'};
      }

      final response = await ioClient.get(Uri.parse(url), headers: headers.isNotEmpty ? headers : null);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) setState(() => cartQty = data['items_count'] ?? 0);
      } else {
        if (mounted) setState(() => cartQty = 0);
      }
    } catch (e) {
      if (mounted) setState(() => cartQty = 0);
    }
  }

  Future<void> saveProductToPrefs(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedProduct = {
      'name': product['name'] ?? '',
      'prodSmallImg': product['prodSmallImg'] ?? '',
      'selectedSize': product['selectedSize'] ?? '',
      'actualPrice': product['actual_price_1'] ?? '',
      'designer_name': product['designer_name'] ?? '',
      'short_desc': product['short_desc'] ?? '',
      'childSku': product['childSku'] ?? '',
    };
    final existing = prefs.getStringList('cartItems') ?? [];
    existing.add(json.encode(selectedProduct));
    await prefs.setStringList('cartItems', existing);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.removeListener(_onScaleUpdate);
    _transformationController.dispose();

    super.dispose();
  }

  void _onScaleUpdate() {
    // Get the current scale from the controller's matrix.
    final scale = _transformationController.value.getMaxScaleOnAxis();

    // If the scale has changed, update the state to rebuild the widget.
    // This allows us to enable/disable the PageView scrolling.
    if (scale != _currentScale) {
      setState(() {
        _currentScale = scale;
      });
    }
  }


  // Future<void> _onAddToWishlistPressed() async {
  //   // 1. Validate size selection
  //   if (selectedSize.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a size to add to wishlist.')),
  //     );
  //     return;
  //   }
  //
  //   // 2. Validate login
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null || customerToken.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please log in to use the wishlist.')),
  //     );
  //     return;
  //   }
  //
  //   setState(() { _isAddingToWishlist = true; });
  //
  //   try {
  //     // 3. Find the simple product SKU for the selected size
  //     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //     final adminTokenResponse = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/integration/admin/token'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'username': 'mahesh', 'password': 'mahesh@123'}),
  //     );
  //     if (adminTokenResponse.statusCode != 200) throw Exception('Failed to get admin token.');
  //     final adminToken = json.decode(adminTokenResponse.body);
  //
  //     final configurableSku = widget.product['prod_sku'];
  //     final childrenResponse = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$configurableSku/children'),
  //       headers: {'Authorization': 'Bearer $adminToken'},
  //     );
  //     if (childrenResponse.statusCode != 200) throw Exception('Failed to get product variants.');
  //
  //     final List<dynamic> children = json.decode(childrenResponse.body);
  //     final matchedChild = children.firstWhere(
  //           (child) => child['sku'].toString().toLowerCase().endsWith(selectedSize.toLowerCase()),
  //       orElse: () => null,
  //     );
  //
  //     if (matchedChild == null) throw Exception('Variant for size $selectedSize not found.');
  //     final String simpleSku = matchedChild['sku'];
  //
  //     print("simplesku>>$simpleSku");
  //
  //     // --- FIX IS HERE: Use the key available on this page: 'prod_en_id' ---
  //     final productId = widget.product['prod_en_id']?.toString();
  //     if (productId == null) throw Exception('Product ID (prod_en_id) is missing from the product data.');
  //
  //
  //     // 4. Save the mapping using this ID
  //     final prefs = await SharedPreferences.getInstance();
  //     final existingMapString = prefs.getString('wishlist_variant_skus') ?? '{}';
  //     final Map<String, dynamic> skuMap = json.decode(existingMapString);
  //
  //     skuMap[productId] = {
  //       'sku': simpleSku,
  //       'size': selectedSize
  //     };
  //
  //     await prefs.setString('wishlist_variant_skus', json.encode(skuMap));
  //     print('Saved to Prefs: ${json.encode({productId: skuMap[productId]})}');
  //     print('[PDP SAVE] Saved to Prefs -> Key: $productId, Value: ${skuMap[productId]}');
  //     // 5. Call the original API to add to server-side wishlist
  //     final success = await _wishlistApiService.addToWishlist(int.parse(productId));
  //
  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added to wishlist!')));
  //       Navigator.push(context, MaterialPageRoute(builder: (context) => WishlistScreen1()));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
  //   } finally {
  //     if (mounted) {
  //       setState(() { _isAddingToWishlist = false; });
  //     }
  //   }
  // }

  void _showSizeInfoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 200, // A smaller, appropriate height
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              const Center(
                child: Text(
                  "Free Size",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFreeSizeInfoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 200, // A smaller, appropriate height
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              const Center(
                child: Text(
                  "Free Size",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override

  void _showSizeChartDialog(BuildContext context) {
    if (sizeOptions.length == 1 && sizeOptions.containsKey("FS")) {
      // If true, show the simple text dialog
      _showFreeSizeInfoDialog(context);
      return; // Stop execution here
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Ensures full-screen modal
      backgroundColor: Colors.transparent, // Make it full screen
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height, // Full height
          width: MediaQuery.of(context).size.width,   // Full width
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    "assets/women_size_chart.png",
                    fit: BoxFit.contain, // Ensures the image fits well
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  void _showAddedToCartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an action
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Added to Cart'),
            ],
          ),
          content: const Text('The item has been added to your shopping bag.'),
          actions: <Widget>[
            // "Continue Shopping" button
            TextButton(
              child: const Text(
                'CONTINUE SHOPPING',
                style: TextStyle(color: Colors.black54),
              ),
              onPressed: () {
                // Just close the dialog
                Navigator.of(dialogContext).pop();
              },
            ),
            // "Checkout" button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('CHECKOUT'),
              onPressed: () {
                // First, close the dialog
                Navigator.of(dialogContext).pop();
                // Then, navigate to the shopping bag screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }





  // Future<void> onAddToCartPressed() async {
  //   if (selectedSize.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a size')),
  //     );
  //     return;
  //   }
  //
  //   HttpClient httpClient = HttpClient();
  //   httpClient.badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final customerToken = prefs.getString('user_token');
  //
  //     if (customerToken == null || customerToken.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('User not logged in.')),
  //       );
  //       return;
  //     }
  //
  //     // Step 1: Get admin token to access configurable children
  //     final adminTokenResponse = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/integration/admin/token'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({
  //         'username': 'mahesh',
  //         'password': 'mahesh@123',
  //       }),
  //     );
  //
  //     if (adminTokenResponse.statusCode != 200) {
  //       print("Failed to generate admin token: ${adminTokenResponse.body}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to authenticate admin.')),
  //       );
  //       return;
  //     }
  //
  //     final adminToken = json.decode(adminTokenResponse.body);
  //
  //     // Step 2: Get child SKUs of configurable product
  //     final sku = widget.product['prod_sku'];
  //     final childrenResponse = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$sku/children'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $adminToken',
  //       },
  //     );
  //
  //     if (childrenResponse.statusCode != 200) {
  //       print("Failed to fetch child SKUs: ${childrenResponse.body}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to fetch product variants.')),
  //       );
  //       return;
  //     }
  //
  //     final List<dynamic> children = json.decode(childrenResponse.body);
  //
  //     final matchedChild = children.firstWhere(
  //           (child) => child['sku'].toString().toLowerCase().endsWith(selectedSize.toLowerCase()),
  //       orElse: () => null,
  //     );
  //
  //     if (matchedChild == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Size $selectedSize not available.')),
  //       );
  //       return;
  //     }
  //
  //     final matchedSku = matchedChild['sku'];
  //     print("Selected SKU: $matchedSku");
  //     String? quoteId;
  //     // Step 3: Get current customer's cart ID (quote_id)
  //     try {
  //       final cartResponse = await ioClient.get(
  //         Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $customerToken',
  //         },
  //       );
  //       if (cartResponse.statusCode == 200) {
  //         final cartJson = json.decode(cartResponse.body);
  //         quoteId = cartJson['id'].toString();
  //         print("Found existing cart (quote) ID: $quoteId");
  //       } else {
  //         // If status is not 200, it means no active cart.
  //         // We will let the 'catch' block handle creating a new one.
  //         throw Exception('No active cart found.');
  //       }
  //     } catch (e) {
  //       // Step 3b: CATCH the error and CREATE a new cart.
  //       print("No active cart found. Creating a new one...");
  //       final createCartResponse = await ioClient.post(
  //         Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //         headers: { 'Authorization': 'Bearer $customerToken' },
  //         // The body is empty for this request
  //       );
  //
  //       if (createCartResponse.statusCode == 200) {
  //         quoteId = json.decode(createCartResponse.body).toString();
  //         print("Created new cart (quote) ID: $quoteId");
  //       } else {
  //         print("Failed to create a new cart: ${createCartResponse.body}");
  //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error creating cart.')));
  //         return; // Stop if we can't create a cart
  //       }
  //     }
  //
  //     // If we reach here, we are GUARANTEED to have a valid quoteId.
  //     if (quoteId == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not get or create a cart.')));
  //       return;
  //     }
  //     // Step 4: Add product to cart
  //     final addToCartResponse = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/items'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $customerToken',
  //       },
  //       body: json.encode({
  //         "cartItem": {
  //           "sku": matchedSku,
  //           "qty": 1,
  //           "quote_id": quoteId,
  //           "product_type": "simple",
  //         }
  //       }),
  //     );
  //
  //     if (addToCartResponse.statusCode == 200) {
  //       _fetchCartQuantity();
  //       print("Product added to cart successfully.");
  //
  //       // Optionally save locally
  //       final selectedProduct = {
  //         ...widget.product,
  //         'selectedSize': selectedSize,
  //         'childSku': matchedSku,
  //       };
  //       await saveProductToPrefs(selectedProduct);
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Product added to cart")),
  //       );
  //
  //       // Uncomment below if you want to navigate to Cart screen
  //       // Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen()));
  //
  //     } else {
  //       print("Failed to add to cart: ${addToCartResponse.body}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to add product to cart')),
  //       );
  //     }
  //   } catch (e) {
  //     print("Exception: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('An error occurred.')),
  //     );
  //   }
  // }


  // Future<void> _fetchCartQuantity() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final customerToken = prefs.getString('user_token');
  //
  //     if (customerToken == null || customerToken.isEmpty) {
  //       setState(() {
  //         cartQty = 0;
  //       });
  //       return;
  //     }
  //
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     final response = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //       headers: {
  //         'Authorization': 'Bearer $customerToken',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final int itemsCount = data['items_count'] ?? 0;
  //       setState(() {
  //         cartQty = itemsCount;
  //       });
  //     } else {
  //       print('Failed to fetch cart>>_fetchCartQuantity: ${response.body}');
  //       setState(() {
  //         cartQty = 0;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error fetching cart quantity: $e');
  //     setState(() {
  //       cartQty = 0;
  //     });
  //   }
  // }








  // Future<void> onAddToCartPressed() async {
  //
  //   if (selectedSize.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a size')),
  //     );
  //     return;
  //   }
  //
  //   HttpClient httpClient = HttpClient();
  //   httpClient.badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   final sku = widget.product['prod_sku'];
  //   print("SKU>>>$sku");
  //   final response = await ioClient.get(
  //     Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$sku/children'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer bgcvi74rodh85vay2yaj7e6leob2dk4w',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> children = json.decode(response.body);
  //     final matchedChild = children.firstWhere(
  //           (child) => child['sku'].toString().toLowerCase().endsWith(selectedSize.toLowerCase()),
  //       orElse: () => null,
  //     );
  //     print("Status code: ${response.statusCode}");
  //     print("Response body: ${response.body}");
  //     if (matchedChild != null) {
  //       final matchedSku = matchedChild['sku'];
  //       // 🛒 Now use `matchedSku` to call your Add-to-Cart API
  //       print("Selected SKU: $matchedSku");
  //
  //       // Example: call addToCart(matchedSku);
  //     } else {
  //       print("No SKU found for size: $selectedSize");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Size $selectedSize not available.')),
  //       );
  //     }
  //   } else {
  //     print("Failed to fetch child SKUs");
  //   }
  // }


// In _ProductDetailNewInDetailScreenState



  // In _ProductDetailNewInDetailScreenState

  @override
  Widget build(BuildContext context) {
    final currencyState = context.watch<CurrencyBloc>().state;
    final List fallbackImages = [
      if (widget.product['prod_small_img'] != null) widget.product['prod_small_img'],
      if (widget.product['prod_thumb_img'] != null) widget.product['prod_thumb_img'],
    ].where((img) => img.isNotEmpty).toList();

    if (fallbackImages.isEmpty) {
      fallbackImages.add('https://placeholder.com/400');
    }

    String displaySymbol = '₹';
    double displayPrice = (widget.product['actual_price_1'] as num?)?.toDouble() ?? 0.0;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      double basePrice = (widget.product['actual_price_1'] as num?)?.toDouble() ?? 0.0;
      double rate = currencyState.selectedRate.rate;
      displayPrice = basePrice * rate;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true, // 👈 ensures the logo is centered
        elevation: 0, // optional: removes shadow for a clean look
        title:   Image.asset('assets/logo.jpeg', height: 30),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_rounded, color: Colors.black),
                if (cartQty > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$cartQty',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
            ),
          ),
        ],
      ),

      // appBar: AppBar(
      //   // title: Text(
      //   //   "Welcome $firstName $lastName",
      //   //   style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
      //   // ),
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       icon: Stack(
      //         clipBehavior: Clip.none,
      //         children: [
      //           const Icon(Icons.shopping_bag_rounded, color: Colors.black),
      //           if (cartQty > 0)
      //             Positioned(
      //               right: -6,
      //               top: -6,
      //               child: Container(
      //                 padding: const EdgeInsets.all(2),
      //                 decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
      //                 constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      //                 child: Text(
      //                   '$cartQty',
      //                   style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      //                   textAlign: TextAlign.center,
      //                 ),
      //               ),
      //             ),
      //         ],
      //       ),
      //       onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen())),
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: _currentScale > 1.0
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Image Section (Vertical Thumbnails + Main Image) ---
                  SizedBox(
                    height: 450,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_areImagesLoading && _productImages.isNotEmpty)
                          SizedBox(
                            width: 80,
                            child: ListView.builder(
                              itemCount: _productImages.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _transformationController.value = Matrix4.identity();
                                    _pageController.jumpToPage(index);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _pageController.hasClients && _pageController.page?.round() == index
                                            ? Colors.black
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _productImages[index].imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _areImagesLoading
                              ? const Center(child: CircularProgressIndicator())
                              : PageView.builder(
                            controller: _pageController,
                            physics: _currentScale > 1.0
                                ? const NeverScrollableScrollPhysics()
                                : const PageScrollPhysics(),
                            onPageChanged: (index) {
                              _transformationController.value = Matrix4.identity();
                            },
                            itemCount: _productImages.isNotEmpty ? _productImages.length : fallbackImages.length,
                            itemBuilder: (context, index) {
                              final imageUrl = _productImages.isNotEmpty
                                  ? _productImages[index].imageUrl
                                  : fallbackImages[index].toString();

                              return GestureDetector(
                                onDoubleTapDown: (details) => _doubleTapDetails = details,
                                onDoubleTap: _handleDoubleTap,
                                child: InteractiveViewer(
                                  transformationController: _transformationController,
                                  minScale: 1.0,
                                  maxScale: 4.0,
                                  onInteractionEnd: (details) {
                                    if (_transformationController.value.getMaxScaleOnAxis() <= 1.0) {
                                      _transformationController.value = Matrix4.identity();
                                    }
                                  },
                                  child: Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => Container(
                                      color: Colors.grey[300],
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Product details (designer, desc, sku, price) ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product['designer_name'] ?? "Unknown Designer",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(widget.product['short_desc'] ?? "No description",
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Text(
                          "$displaySymbol${displayPrice.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        const SizedBox(height: 5),
                        Text("SKU: ${widget.product['prod_sku'] ?? 'N/A'}",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  // --- Sizes + Size chart ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_areDetailsLoading)
                          const SizedBox(
                            height: 55,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        else if (sizeOptions.isNotEmpty)
                          SizedBox(
                            // Increased height to accommodate larger circles
                            height: (sizeOptions.length / 5).ceil() * 70.0,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                // Adjusted aspect ratio for bigger circles
                                childAspectRatio: 1.0,
                              ),
                              itemCount: sizeOptions.length,
                              itemBuilder: (context, index) {
                                final displayKey = sizeOptions.keys.elementAt(index);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSizeIndex = index;
                                      selectedSizeDisplayValue = displayKey;
                                      selectedSizeApiValue = sizeOptions[displayKey]!;
                                    });
                                  },
                                  child: Container(
                                    height: 55, // increased diameter
                                    width: 55,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black, width: 1.5),
                                      color: selectedSizeIndex == index ? Colors.black : Colors.white,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      displayKey,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: selectedSizeIndex == index ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _showSizeChartDialog(context),
                          child: Row(
                            children: const [
                              Text(
                                "Size Chart",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.insert_chart, size: 24, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       if (_areDetailsLoading)
                  //         const SizedBox(height: 55, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                  //       else if (sizeOptions.isNotEmpty)
                  //         SizedBox(
                  //           height: (sizeOptions.length / 5).ceil() * 55.0,
                  //           child: GridView.builder(
                  //             physics: const NeverScrollableScrollPhysics(),
                  //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //               crossAxisCount: 5,
                  //               crossAxisSpacing: 6,
                  //               mainAxisSpacing: 6,
                  //               childAspectRatio: 1.45,
                  //             ),
                  //             itemCount: sizeOptions.length,
                  //             itemBuilder: (context, index) {
                  //               final displayKey = sizeOptions.keys.elementAt(index);
                  //               return GestureDetector(
                  //                 onTap: () {
                  //                   setState(() {
                  //                     selectedSizeIndex = index;
                  //                     selectedSizeDisplayValue = displayKey;
                  //                     selectedSizeApiValue = sizeOptions[displayKey]!;
                  //                   });
                  //                 },
                  //                 child: Container(
                  //                   decoration: BoxDecoration(
                  //                     shape: BoxShape.circle,
                  //                     border: Border.all(color: Colors.black),
                  //                     color: selectedSizeIndex == index ? Colors.black : Colors.white,
                  //                   ),
                  //                   alignment: Alignment.center,
                  //                   child: Text(
                  //                     displayKey,
                  //                     style: TextStyle(
                  //                       fontSize: 12,
                  //                       fontWeight: FontWeight.bold,
                  //                       color: selectedSizeIndex == index ? Colors.white : Colors.black,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               );
                  //             },
                  //           ),
                  //         ),
                  //       const SizedBox(height: 16),
                  //       GestureDetector(
                  //         onTap: () => _showSizeChartDialog(context),
                  //         child: Row(
                  //           children: const [
                  //             Text("Size Chart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  //             SizedBox(width: 5),
                  //             Icon(Icons.insert_chart, size: 24, color: Colors.black),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const Divider(thickness: 2, indent: 20, endIndent: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Ship In: ${(widget.product['child_delivery_time'] is List) ? widget.product['child_delivery_time'].join(", ") : widget.product['child_delivery_time'] ?? "Not specified"}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const Divider(thickness: 2, indent: 20, endIndent: 20),

                  // --- Buttons: Buy Now, Add to Cart, Wishlist ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // 🟢 Step 1: Add product to cart first
                              await onAddToCartPressed();

                              // 🟢 Step 2: Then navigate to CheckoutScreen
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => CheckoutScreen()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(60, 60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            child: const Text(
                              "BUY NOW",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: onAddToCartPressed,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    minimumSize: const Size(60, 60),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                                child: const Text("ADD TO CART", style: TextStyle(color: Colors.white)))),
                        const SizedBox(width: 10),
                        _isAddingToWishlist
                            ? const CircularProgressIndicator()
                            : IconButton(icon: const Icon(Icons.favorite_border, size: 30), onPressed: _onAddToWishlistPressed),
                      ],
                    ),
                  ),

                  // --- Details & Disclaimer ---
                  ExpansionTile(
                    title: const Text("DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          (widget.product['prod_desc'] is List)
                              ? widget.product['prod_desc'].join(", ")
                              : widget.product['prod_desc'] ?? "No details available",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 2, indent: 20, endIndent: 20),
                  ExpansionTile(
                    title: const Text("DISCLAIMER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Disclaimer:\nThis product is made to order.\nProduct color may slightly vary due to photographic lighting sources or your monitor setting.\nFor any sizing queries please connect with us on +91 83750 36648\n\n${widget.product['disclaimer'] ?? ''}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  // --- Discover More section ---
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center, // 👈 Centers children horizontally
                        children: [
                          const Text(
                            "DISCOVER MORE",
                            textAlign: TextAlign.center, // 👈 Centers text within its own box
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            height: 2,
                            width: 100,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  ),

                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          indicatorColor: Colors.black,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: "You may also like"),
                            Tab(text: "More from designer"),
                          ],
                        ),
                        SizedBox(
                          height: 350,
                          child: TabBarView(
                            children: [
                              _isLoadingSuggestions
                                  ? const Center(child: CircularProgressIndicator())
                                  : _buildProductCarousel(_youMayAlsoLikeProducts),
                              _isLoadingDesigner
                                  ? const Center(child: CircularProgressIndicator())
                                  : _buildProductCarousel(_designerProducts),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Bottom support bar ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: Column(
              children: [
                const Text("CUSTOMER SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _supportButton(Icons.chat, "Chat With Us", () => _openWhatsApp("+918375036648")),
                    _supportButton(Icons.phone, "+91 8375036648", () => _makePhoneCall("+918375036648")),
                    _supportButton(Icons.email, "Mail us", () => _sendEmail("customercare@aashniandco.com")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  //24/09/2025
  // Widget build(BuildContext context) {
  //   final currencyState = context.watch<CurrencyBloc>().state;
  //   final List fallbackImages = [
  //     if (widget.product['prod_small_img'] != null) widget.product['prod_small_img'],
  //     if (widget.product['prod_thumb_img'] != null) widget.product['prod_thumb_img'],
  //   ].where((img) => img.isNotEmpty).toList();
  //
  //   if (fallbackImages.isEmpty) {
  //     fallbackImages.add('https://placeholder.com/400');
  //   }
  //
  //   String displaySymbol = '₹';
  //   double displayPrice = (widget.product['actual_price_1'] as num?)?.toDouble() ?? 0.0;
  //
  //   if (currencyState is CurrencyLoaded) {
  //     displaySymbol = currencyState.selectedSymbol;
  //     double basePrice = (widget.product['actual_price_1'] as num?)?.toDouble() ?? 0.0;
  //     double rate = currencyState.selectedRate.rate;
  //     displayPrice = basePrice * rate;
  //   }
  //
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text("Welcome $firstName $lastName", style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold)),
  //       backgroundColor: Colors.white,
  //       centerTitle: true,
  //       actions: [
  //         IconButton(
  //           icon: Stack(
  //             clipBehavior: Clip.none,
  //             children: [
  //               const Icon(Icons.shopping_bag_rounded, color: Colors.black),
  //               if (cartQty > 0)
  //                 Positioned(
  //                   right: -6, top: -6,
  //                   child: Container(
  //                     padding: const EdgeInsets.all(2),
  //                     decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
  //                     constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
  //                     child: Text('$cartQty', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
  //                   ),
  //                 ),
  //             ],
  //           ),
  //           onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen())),
  //         ),
  //       ],
  //     ),
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: SingleChildScrollView(
  //             physics: _currentScale > 1.0 ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 SizedBox(
  //                   height: 400,
  //                   child: _areImagesLoading
  //                       ? const Center(child: CircularProgressIndicator())
  //                       : PageView.builder(
  //                     controller: _pageController,
  //                     physics: _currentScale > 1.0
  //                         ? const NeverScrollableScrollPhysics()
  //                         : const PageScrollPhysics(),
  //                     onPageChanged: (index) {
  //                       _transformationController.value = Matrix4.identity();
  //                     },
  //                     itemCount: _productImages.isNotEmpty ? _productImages.length : fallbackImages.length,
  //                     itemBuilder: (context, index) {
  //                       final imageUrl = _productImages.isNotEmpty
  //                           ? _productImages[index].imageUrl
  //                           : fallbackImages[index].toString();
  //
  //                       // ✅ WRAP THE INTERACTIVEVIEWER WITH GESTUREDETECTOR
  //                       return GestureDetector(
  //                         // Store the tap details for precise zoom
  //                         onDoubleTapDown: (details) => _doubleTapDetails = details,
  //                         // Execute the zoom logic
  //                         onDoubleTap: _handleDoubleTap,
  //                         child: InteractiveViewer(
  //                           transformationController: _transformationController,
  //                           minScale: 1.0,
  //                           maxScale: 4.0,
  //                           onInteractionEnd: (details) {
  //                             if (_transformationController.value.getMaxScaleOnAxis() <= 1.0) {
  //                               _transformationController.value = Matrix4.identity();
  //                             }
  //                           },
  //                           child: Image.network(
  //                             imageUrl,
  //                             width: double.infinity,
  //                             fit: BoxFit.contain,
  //                             errorBuilder: (c, e, s) => Container(
  //                               color: Colors.grey[300],
  //                               alignment: Alignment.center,
  //                               child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 // The thumbnail slider remains the same
  //                 if (!_areImagesLoading && _productImages.isNotEmpty)
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //                     child: SizedBox(
  //                       height: 80,
  //                       child: ListView.builder(
  //                         scrollDirection: Axis.horizontal,
  //                         itemCount: _productImages.length,
  //                         itemBuilder: (context, index) {
  //                           return GestureDetector(
  //                             onTap: () {
  //                               _transformationController.value = Matrix4.identity();
  //                               _pageController.animateToPage(
  //                                 index,
  //                                 duration: const Duration(milliseconds: 300),
  //                                 curve: Curves.easeInOut,
  //                               );
  //                             },
  //                             child: Container(
  //                               width: 80, margin: const EdgeInsets.symmetric(horizontal: 4.0),
  //                               decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
  //                               child: ClipRRect(borderRadius: BorderRadius.circular(8),
  //                                 child: Image.network(_productImages[index].imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey)),
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                   ),
  //
  //                 Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(widget.product['designer_name'] ?? "Unknown Designer", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
  //                       const SizedBox(height: 5),
  //                       Text(widget.product['short_desc'] ?? "No description", style: const TextStyle(fontSize: 16)),
  //                       const SizedBox(height: 10),
  //                       Text(
  //                           "$displaySymbol${displayPrice.toStringAsFixed(0)}",
  //                           style: const TextStyle(fontSize: 20, color: Colors.black)
  //                       ),
  //                       const SizedBox(height: 5),
  //                       Text("SKU: ${widget.product['prod_sku'] ?? 'N/A'}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
  //                     ],
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       if (_areDetailsLoading)
  //                         const SizedBox(height: 55, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
  //                       else if (sizeOptions.isNotEmpty)
  //                         SizedBox(
  //                           height: (sizeOptions.length / 5).ceil() * 55.0,
  //                           child: GridView.builder(
  //                             physics: const NeverScrollableScrollPhysics(),
  //                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //                               crossAxisCount: 5,
  //                               crossAxisSpacing:6,
  //                               mainAxisSpacing: 6,
  //                               childAspectRatio: 1.45,
  //                             ),
  //                             itemCount: sizeOptions.length,
  //                             itemBuilder: (context, index) {
  //                               final displayKey = sizeOptions.keys.elementAt(index);
  //                               return GestureDetector(
  //                                 onTap: () {
  //                                   setState(() {
  //                                     selectedSizeIndex = index;
  //                                     selectedSizeDisplayValue = displayKey;
  //                                     selectedSizeApiValue = sizeOptions[displayKey]!;
  //                                   });
  //                                 },
  //                                 child: Container(
  //                                   decoration: BoxDecoration(
  //                                     shape: BoxShape.circle,
  //                                     border: Border.all(color: Colors.black),
  //                                     color: selectedSizeIndex == index ? Colors.black : Colors.white,
  //                                   ),
  //                                   alignment: Alignment.center,
  //                                   child: Text(
  //                                     displayKey,
  //                                     style: TextStyle(
  //                                       fontSize: 12,
  //                                       fontWeight: FontWeight.bold,
  //                                       color: selectedSizeIndex == index ? Colors.white : Colors.black,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                         ),
  //
  //                       const SizedBox(height: 16),
  //                       GestureDetector(
  //                         onTap: () => _showSizeChartDialog(context),
  //                         child: Row(
  //                           children: [
  //                             const Text("Size Chart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //                             const SizedBox(width: 5),
  //                             const Icon(Icons.insert_chart, size: 24, color: Colors.black),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Divider(
  //                   color: Colors.grey,   // line color
  //                   thickness: 2,         // line thickness
  //                   indent: 20,           // left padding
  //                   endIndent: 20,        // right padding
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Text(
  //                     "Ship In: ${(widget.product['child_delivery_time'] is List)
  //                         ? widget.product['child_delivery_time'].join(", ")
  //                         : widget.product['child_delivery_time'] ?? "Not specified"}",
  //                     style: const TextStyle(fontSize: 14),
  //                   ),
  //
  //                 ),
  //                 Divider(
  //                   color: Colors.grey,   // line color
  //                   thickness: 2,         // line thickness
  //                   indent: 20,           // left padding
  //                   endIndent: 20,        // right padding
  //                 ),
  //
  //                 Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Row(
  //                     children: [
  //                       Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(60, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)), child: const Text("BUY NOW", style: TextStyle(color: Colors.white)))),
  //                       const SizedBox(width: 10),
  //                       Expanded(child: ElevatedButton(onPressed: onAddToCartPressed, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(60, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)), child: const Text("ADD TO CART", style: TextStyle(color: Colors.white)))),
  //                       const SizedBox(width: 10),
  //                       _isAddingToWishlist ? const CircularProgressIndicator() : IconButton(icon: const Icon(Icons.favorite_border, size: 30), onPressed: _onAddToWishlistPressed),
  //                     ],
  //                   ),
  //                 ),
  //                 ExpansionTile(
  //                   title: const Text("DETAILS", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
  //                   children: [
  //                     Padding(padding: const EdgeInsets.all(16.0), child: Text((widget.product['prod_desc'] is List) ? widget.product['prod_desc'].join(", ") : widget.product['prod_desc'] ?? "No details available", style: const TextStyle(fontSize: 14))),
  //                   ],
  //                 ),
  //                 Divider(
  //                   color: Colors.grey,   // line color
  //                   thickness: 2,         // line thickness
  //                   indent: 20,           // left padding
  //                   endIndent: 20,        // right padding
  //                 ),
  //                 ExpansionTile(
  //                   title: const Text("DISCLAIMER", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
  //                   children: [
  //                     Padding(padding: const EdgeInsets.all(16.0), child: Text("Disclaimer:\nThis product is made to order.\nProduct color may slightly vary due to photographic lighting sources or your monitor setting.\nFor any sizing queries please connect with us on +91 83750 36648\n\n${widget.product['disclaimer'] ?? ''}", style: const TextStyle(fontSize: 14))),
  //                   ],
  //                 ),
  //
  //
  //                 const SizedBox(height: 20),
  //                 // --- START OF NEW WIDGETS FOR "DISCOVER MORE" ---
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(vertical: 20.0),
  //                   child: Column(
  //                     children: [
  //                       const Text(
  //                         "DISCOVER MORE",
  //                         style: TextStyle(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.bold,
  //                           letterSpacing: 1.5,
  //                         ),
  //                       ),
  //                       Container(
  //                         margin: const EdgeInsets.symmetric(vertical: 10),
  //                         height: 2,
  //                         width: 100, // Adjust width as needed
  //                         color: Colors.grey[300],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 DefaultTabController(
  //                   length: 2,
  //                   child: Column(
  //                     children: [
  //                       const TabBar(
  //                         indicatorColor: Colors.black,
  //                         labelColor: Colors.black,
  //                         unselectedLabelColor: Colors.grey,
  //                         tabs: [
  //                           Tab(text: "You may also like"),
  //                           Tab(text: "More from designer"),
  //                         ],
  //                       ),
  //                       SizedBox(
  //                         height: 350,
  //                         child: TabBarView(
  //                           children: [
  //                             // --- Tab 1: You may also like ---
  //                             _isLoadingSuggestions
  //                                 ? const Center(child: CircularProgressIndicator())
  //                                 : _buildProductCarousel(_youMayAlsoLikeProducts),
  //
  //                             // --- Tab 2: More from designer ---
  //                             _isLoadingDesigner
  //                                 ? const Center(child: CircularProgressIndicator())
  //                                 : _buildProductCarousel(_designerProducts),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 )
  //
  //                 ,
  //
  //               ],
  //             ),
  //           ),
  //         ),
  //         Container(
  //           padding: const EdgeInsets.symmetric(vertical: 10),
  //           color: Colors.white,
  //           child: Column(
  //             children: [
  //               const Text("CUSTOMER SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //               const SizedBox(height: 10),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   _supportButton(Icons.chat, "Chat With Us", () => _openWhatsApp("+918375036648")),
  //                   _supportButton(Icons.phone, "+91 8375036648", () => _makePhoneCall("+918375036648")),
  //                   _supportButton(Icons.email, "Mail us", () => _sendEmail("customercare@aashniandco.com")),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }




  Widget _supportButton(IconData icon, String text, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          onPressed: onPressed,
        ),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }




  void _openWhatsApp(String phone) async {
    String url;


    if (Platform.isAndroid) {
      url = "whatsapp://send?phone=$phone";
    } else if (Platform.isIOS) {
      print("whatsapp IOS clicked>>");
      url = "https://wa.me/$phone";
    } else {
      url = "https://wa.me/$phone";
    }


    // Ensure launchUrl is called
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }




  void _makePhoneCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");


    if (await canLaunchUrl(url)) {
      print("Launching dialer...");
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("Error: Cannot launch dialer for $phone");
    }
  }




  void _sendEmail(String email) async {
    final Uri url = Uri.parse("mailto:$email"); // ✅ Correct scheme


    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Could not launch email for $email");
    }
  }

  // In _ProductDetailNewInDetailScreenState
  //
  Widget _buildProductCarousel(List<Map<String, dynamic>> products) {
    final currencyState = context.watch<CurrencyBloc>().state;
    String displaySymbol = '₹';
    double currentRate = 1.0;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      currentRate = currencyState.selectedRate.rate;
    }

    // ✅ --- START OF CHANGE --- ✅
    // Filter the list right at the beginning of the build method.
    // This is the most reliable place to ensure no zero-price items get through.
    final filteredProducts = products.where((p) {
      final price = (p['actual_price_1'] as num?)?.toDouble() ?? 0.0;
      return price > 1.0;
    }).toList();
    // ✅ --- END OF CHANGE --- ✅


    // Now, check if the *filtered* list is empty.
    if (filteredProducts.isEmpty) {
      return const Center(child: Text("No products found."));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: 320, // increased from 280
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            double basePrice = (product['actual_price_1'] as num?)?.toDouble() ?? 0.0;
            double convertedPrice = basePrice * currentRate;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailNewInDetailScreen(product: product),
                  ),
                );
              },
              child: Container(
                width: 170,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product['prod_small_img'] ?? 'https://via.placeholder.com/150',
                        height: 200, // increased height
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              product['designer_name'] ?? "Unknown Designer",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              product['short_desc'] ?? "",
                              textAlign: TextAlign.center, // 🧩 makes multi-line text centered too
                              style: const TextStyle(fontSize: 12, color: Colors.black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              "$displaySymbol${convertedPrice.toStringAsFixed(0)}",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

    );
  }

// 1/11/2025
//   Widget _buildProductCarousel(List<Map<String, dynamic>> products) {
//     final currencyState = context.watch<CurrencyBloc>().state;
//     String displaySymbol = '₹';
//     double currentRate = 1.0;
//
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       currentRate = currencyState.selectedRate.rate;
//     }
//
//     // ✅ --- START OF CHANGE --- ✅
//     // Filter the list right at the beginning of the build method.
//     // This is the most reliable place to ensure no zero-price items get through.
//     final filteredProducts = products.where((p) {
//       final price = (p['actual_price_1'] as num?)?.toDouble() ?? 0.0;
//       return price > 1.0;
//     }).toList();
//     // ✅ --- END OF CHANGE --- ✅
//
//     if (products.isEmpty) {
//       return const Center(child: Text("No products found."));
//     }
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12.0),
//       child: SizedBox(
//         height: 280, // Increased height for extra details
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: products.length,
//           itemBuilder: (context, index) {
//             final product = products[index];
//
//             double basePrice = (product['actual_price_1'] as num?)?.toDouble() ?? 0.0;
//             double convertedPrice = basePrice * currentRate;
//
//
//
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ProductDetailNewInDetailScreen(product: product),
//                   ),
//                 );
//               },
//               child: Container(
//                 width: 170,
//                 margin: const EdgeInsets.symmetric(horizontal: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                       child: Image.network(
//                         product['prod_small_img'] ?? 'https://via.placeholder.com/150',
//                         height: 140,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                         errorBuilder: (c, e, s) => Container(
//                           color: Colors.grey[300],
//                           alignment: Alignment.center,
//                           child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             product['designer_name'] ?? "Unknown Designer",
//                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             product['short_desc'] ?? "",
//                             style: const TextStyle(fontSize: 12, color: Colors.black54),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             "$displaySymbol${convertedPrice.toStringAsFixed(0)}",
//                             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 6),
//
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

  // Widget _buildProductCarousel(List<Map<String, dynamic>> products) {
  //   final currencyState = context.watch<CurrencyBloc>().state;
  //   String displaySymbol = '₹';
  //   double displayPrice = (widget.product['actual_price_1'] as num?)?.toDouble() ?? 0.0;
  //
  //   if (currencyState is CurrencyLoaded) {
  //     displaySymbol = currencyState.selectedSymbol;
  //     double basePrice = (widget.product['actual_price_1'] as num?)?.toDouble() ?? 0.0;
  //     double rate = currencyState.selectedRate.rate;
  //     displayPrice = basePrice * rate;
  //   }
  //   if (products.isEmpty) {
  //     return const Center(child: Text("No products found."));
  //   }
  //
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 12.0),
  //     child: SizedBox(
  //       height: 250,
  //       child: ListView.builder(
  //         scrollDirection: Axis.horizontal,
  //         itemCount: products.length,
  //         itemBuilder: (context, index) {
  //           final product = products[index];
  //           return Container(
  //             width: 160,
  //             margin: const EdgeInsets.symmetric(horizontal: 8),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(12),
  //               boxShadow: [
  //                 BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
  //               ],
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 ClipRRect(
  //                   borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
  //                   child: Image.network(
  //                     product['prod_small_img'] ?? 'https://via.placeholder.com/150',
  //                     height: 140,
  //                     width: double.infinity,
  //                     fit: BoxFit.cover,
  //                     errorBuilder: (c, e, s) => Container(
  //                       color: Colors.grey[300],
  //                       alignment: Alignment.center,
  //                       child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
  //                     ),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         product['designer_name'] ?? "Unknown Designer",
  //                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                       const SizedBox(height: 4),
  //                       Text(
  //                         product['short_desc'] ?? "",
  //                         style: const TextStyle(fontSize: 12, color: Colors.black54),
  //                         maxLines: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                       const SizedBox(height: 6),
  //                       // Text(
  //                       //     "$displaySymbol${displayPrice.toStringAsFixed(0)}",
  //                       //     style: const TextStyle(fontSize: 20, color: Colors.black)
  //                       // ),
  //                       Text(
  //                         "₹${(product['actual_price_1'] as num?)?.toStringAsFixed(0) ?? '--'}",
  //                         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }







}


// class ProductDetailNewInDetailScreen extends StatefulWidget {
//   final Product product;
//
//   const ProductDetailNewInDetailScreen({super.key, required this.product});
//
//   @override
//   State<ProductDetailNewInDetailScreen> createState() => _ProductDetailNewInDetailScreenState();
// }
//
// class _ProductDetailNewInDetailScreenState extends State<ProductDetailNewInDetailScreen> {
//   int selectedSizeIndex = 0; // Default selected size
//   // List<String> sizes = ["S", "M", "L"]; // Dummy size options
//   List<String> sizes = [];
//   late PageController _pageController;
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(widget.product.designerName, style: const TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         iconTheme: const IconThemeData(color: Colors.black),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.shopping_cart),
//             onPressed: () {
//               // Navigate to cart screen
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Product Image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   widget.product.prodSmallImg,
//                   width: double.infinity,
//                   height: 500,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     height: 500,
//                     color: Colors.grey[300],
//                     alignment: Alignment.center,
//                     child: const Icon(Icons.image_not_supported, size: 50),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Designer Name
//               Center(
//                 child: Text(
//                   widget.product.designerName,
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//
//               const SizedBox(height: 8),
//
//               // Description
//               Center(
//                 child: Text(
//                   widget.product.shortDesc,
//                   style: const TextStyle(fontSize: 14, color: Colors.black54),
//                   maxLines: 2,
//                   textAlign: TextAlign.center,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Price
//               Center(
//                 child: Text(
//                   "₹${widget.product.actualPrice.toStringAsFixed(0)}",
//                   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Add to Cart Button
//               Center(
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Add to cart logic
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text(
//                       'Add to Cart',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               // Product Specs
//               const Text(
//                 'Product Specifications',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//
//               const SizedBox(height: 8),
//
//               const Text(
//                 '• Material: Cotton\n• Color: Beige\n• Fit: Regular\n• Wash Care: Dry Clean Only',
//                 style: TextStyle(fontSize: 14),
//               ),
//
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }