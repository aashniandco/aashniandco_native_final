import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:http/http.dart';
import 'package:aashniandco/features/newin/bloc/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/api_constants.dart';
import '../model/new_in_model.dart';
import 'new_in_products_event.dart';
import 'new_in_products_state.dart';

// class NewInProductsBloc extends Bloc<NewInProductsEvent, NewInProductsState> {
//   final ProductRepository productRepository;
//   final String subcategory;
//   final List<Map<String, dynamic>>? selectedCategories;
//
//   NewInProductsBloc({
//     required this.productRepository,
//     required this.subcategory,
//     this.selectedCategories,
//   }) : super(NewInProductsInitial()) {
//     on<FetchProductsEvent>(_onFetchProducts);
//     on<FetchProductsByGenderEvent>(_onFetchProductsByGender);
//     on<SortProductsEvent>(_onSortProducts);
//   }
//
//   // ✅ Gender-based Products Fetching
//
//   Future<void> _onFetchProductsByGender(
//       FetchProductsByGenderEvent event,
//       Emitter<NewInProductsState> emit,
//       ) async {
//     emit(NewInProductsLoading());
//     try {
//       final products = await productRepository.fetchProductsByGender(event.genderName);
//       emit(NewInProductsLoaded(products.cast<Product>()));
//
//     } catch (e) {
//       emit(NewInProductsError(message: "Failed to load gender-based products"));
//     }
//   }
//
//   // ✅ Subcategory-based Products Fetching
//   Future<void> _onFetchProducts(
//       FetchProductsEvent event,
//       Emitter<NewInProductsState> emit,
//       ) async {
//     emit(NewInProductsLoading());
//
//     try {
//       final allProducts = <Product>[];
//       final apiUrls = await ApiConstants.getApiUrlForSubcategory(subcategory);
//
//       print('🔗 API Called for "$subcategory": $apiUrls');
//       print('Type of apiUrls: ${apiUrls.runtimeType}');
//
//       if (apiUrls is String) {
//         print('📦 Fetching from single API: $apiUrls');
//         final products = await productRepository.fetchProductsBySubcategory(apiUrls);
//         allProducts.addAll(products);
//       } else if (apiUrls is List<String>) {
//         print('📦 Fetching from multiple APIs: $apiUrls');
//         for (var url in apiUrls) {
//           print('📦 Fetching from: $url');
//           final products = await productRepository.fetchProductsBySubcategory(url);
//           allProducts.addAll(products);
//         }
//       } else {
//         print("🚨 apiUrls is neither a String nor a List<String>: $apiUrls");
//       }
//
//       emit(NewInProductsLoaded(allProducts));
//     } catch (e) {
//       print("❌ Error in _onFetchProducts: $e");
//       emit(NewInProductsError(message: "Failed to load products"));
//     }
//   }
//
//   // ✅ Sort Products by Price
//   void _onSortProducts(
//       SortProductsEvent event,
//       Emitter<NewInProductsState> emit,
//       ) {
//     if (state is NewInProductsLoaded) {
//       final currentState = state as NewInProductsLoaded;
//       final sortedProducts = [...currentState.products];
//
//       sortedProducts.sort((a, b) {
//         final priceA = a.actualPrice;
//         final priceB = b.actualPrice;
//         return event.sortOrder == SortOrder.lowToHigh
//             ? priceA.compareTo(priceB)
//             : priceB.compareTo(priceA);
//       });
//
//       emit(NewInProductsLoaded(sortedProducts));
//     }
//   }
// }

class NewInProductsBloc extends Bloc<NewInProductsEvent, NewInProductsState> {
  final ProductRepository productRepository;
  final String subcategory;
  final List<Map<String, dynamic>>? selectedCategories;

  NewInProductsBloc({
    required this.productRepository,
    required this.subcategory,
    this.selectedCategories,
  }) : super(NewInProductsInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    // on<FetchProductsByGenderEvent>(_onFetchProductsByGender);
    on<FetchProductsByGendersEvent>((event, emit) async {
      emit(NewInProductsLoading());
      try {
        final products = await productRepository.fetchProductsByGenders(event.genders);
        emit(NewInProductsLoaded(products));
      } catch (e) {
        emit(NewInProductsError(message: "Error: ${e.toString()}"));
      }
    });

    on<FetchProductsByThemesEvent>((event, emit) async {
      emit(NewInProductsLoading());
      try {
        final products = await productRepository.fetchProductsByThemes(event.themes);
        emit(NewInProductsLoaded(products));
      } catch (e) {
        emit(NewInProductsError(message: "Error: ${e.toString()}"));
      }
    });

    on<FetchProductsByColorsEvent>((event, emit) async {
      emit(NewInProductsLoading());
      try {
        final products = await productRepository.fetchProductsByColors(event.colors);
        emit(NewInProductsLoaded(products));
      } catch (e) {
        emit(NewInProductsError(message: "Error: ${e.toString()}"));
      }
    });

    on<FetchProductsBySizesEvent>((event, emit) async {
      emit(NewInProductsLoading());
      try {
        final products = await productRepository.fetchProductsBySize(event.sizes);
        emit(NewInProductsLoaded(products));
      } catch (e) {
        emit(NewInProductsError(message: "Error: ${e.toString()}"));
      }
    });
    on<FetchProductsByShipsinEvent>((event, emit) async {
      emit(NewInProductsLoading());
      try {
        final products = await productRepository.fetchProductsByShipin(event.shipsin);
        emit(NewInProductsLoaded(products));
      } catch (e) {
        emit(NewInProductsError(message: "Error: ${e.toString()}"));
      }
    });

    on<FetchProductsByAcoEditEvent>((event, emit) async {
      emit(NewInProductsLoading());
      try {
        final products = await productRepository.fetchProductsByAcoEdit(event.acoedit);
        emit(NewInProductsLoaded(products));
      } catch (e) {
        emit(NewInProductsError(message: "Error: ${e.toString()}"));
      }
    });

    on<FetchProductsByOccassionsEvent>((event, emit) async {
      emit(NewInProductsLoading());
      try {
        final products = await productRepository.fetchProductsByOccassions(event.occassions);
        emit(NewInProductsLoaded(products));
      } catch (e) {
        emit(NewInProductsError(message: "Error: ${e.toString()}"));
      }
    });

    on<FetchProductsByPricesEvent>((event, emit) async {
      emit(NewInProductsLoading());
      try {
        final products = await productRepository.fetchProductsByPrices(event.price);
        emit(NewInProductsLoaded(products));
      } catch (e) {
        emit(NewInProductsError(message: "Error: ${e.toString()}"));
      }
    });


    on<FetchProductsBySubcategoryFilterEvent>((event, emit) async {
      emit(NewInProductsLoading());
      try {
        final products = await productRepository.fetchProductsBySubCategoryFilter(event.subcategories);
        emit(NewInProductsLoaded(products));
      } catch (e) {
        emit(NewInProductsError(message: "Error: ${e.toString()}"));
      }
    });



    on<FetchProductsByCategoryFilterEvent>((event, emit) async {
      emit(NewInProductsLoading());
      try {
        final products = await productRepository.fetchProductsByCategoryFilter(event.cat_filter);
        emit(NewInProductsLoaded(products));
      } catch (e) {
        emit(NewInProductsError(message: "Error: ${e.toString()}"));
      }
    });

    on<SortProductsEvent>(_onSortProducts);
  }

  Future<void> _onFetchProducts(FetchProductsEvent event, Emitter<NewInProductsState> emit) async {
    emit(NewInProductsLoading());

    try {
      final allProducts = <Product>[];

      // Get API URLs for the selected subcategory
      final apiUrls = await ApiConstants.getApiUrlForSubcategory(subcategory);
      print('🔗 API Called for "$subcategory": $apiUrls');

      if (apiUrls is String) {
        final products = await productRepository.fetchProductsBySubcategory(apiUrls);
        allProducts.addAll(products);
      } else if (apiUrls is List<String>) {
        for (var url in apiUrls) {
          final products = await productRepository.fetchProductsBySubcategory(url);
          allProducts.addAll(products);
        }
      }

      // ✅ Default sort by latest (prod_en_id descending)
      allProducts.sort((a, b) {
        final idA = int.tryParse(a.prod_en_id) ?? 0;
        final idB = int.tryParse(b.prod_en_id) ?? 0;
        return idB.compareTo(idA); // Higher ID = more recent
      });

      emit(NewInProductsLoaded(allProducts));
    } catch (e) {
      print("❌ Error in _onFetchProducts: $e");
      emit(NewInProductsError(message: "Failed to load products"));
    }
  }


  // Future<void> _onFetchProducts(FetchProductsEvent event, Emitter<NewInProductsState> emit) async {
  //   emit(NewInProductsLoading());
  //
  //   try {
  //     final allProducts = <Product>[];
  //
  //     // Get API URLs for the selected subcategories
  //     final apiUrls = await ApiConstants.getApiUrlForSubcategory(subcategory);  // Add await here
  //     print('🔗 API Called for "$subcategory": $apiUrls');
  //     print('Type of apiUrls: ${apiUrls.runtimeType}');  // Log the type of apiUrls
  //
  //     // Check if the apiUrls is a String (single URL)
  //     if (apiUrls is String) {
  //       print('📦 Fetching from single API: $apiUrls');
  //       final products = await productRepository.fetchProductsBySubcategory(apiUrls);
  //       allProducts.addAll(products);
  //     }
  //     // Check if the apiUrls is a List of Strings (multiple APIs)
  //     else if (apiUrls is List<String>) {
  //       print('📦 Fetching from multiple APIs: $apiUrls');
  //       for (var url in apiUrls) {
  //         print('📦 Fetching from: $url');
  //         final products = await productRepository.fetchProductsBySubcategory(url);
  //         allProducts.addAll(products);
  //       }
  //     } else {
  //       print("🚨 apiUrls is neither a String nor a List<String>: $apiUrls");
  //     }
  //
  //     emit(NewInProductsLoaded(allProducts));
  //
  //   } catch (e) {
  //     print("❌ Error in _onFetchProducts: $e");
  //     emit(NewInProductsError(message: "Failed to load products"));
  //   }
  // }

  // Future<void> _onFetchProducts(FetchProductsEvent event, Emitter<NewInProductsState> emit) async {
  //   emit(NewInProductsLoading());
  //
  //   try {
  //     final allProducts = <Product>[];
  //
  //     // Get API URLs for the selected subcategory (await the result)
  //     final apiUrls = await ApiConstants.getApiUrlForSubcategory(subcategory);
  //     print('🔗 API Called for "$subcategory": $apiUrls');
  //
  //     // Case 1: If a single API URL is returned (string), call that API
  //     if (apiUrls is String) {
  //       print('📦 Fetching from: $apiUrls');
  //       final products = await productRepository.fetchProductsBySubcategory(apiUrls);
  //       allProducts.addAll(products);
  //     }
  //     // Case 2: If multiple API URLs are returned (list), loop through and call each API
  //     else if (apiUrls is List<String>) {
  //       for (var url in apiUrls) {
  //         print('📦 Fetching from:>>> $url');
  //         final products = await productRepository.fetchProductsBySubcategory(url);
  //         allProducts.addAll(products);
  //       }
  //     }
  //
  //     emit(NewInProductsLoaded(allProducts));
  //
  //   } catch (e) {
  //     print("❌ Error in _onFetchProducts: $e");
  //     emit(NewInProductsError(message: "Failed to load products"));
  //   }
  // }

  // void _onSortProducts(SortProductsEvent event, Emitter<NewInProductsState> emit) {
  //   if (state is NewInProductsLoaded) {
  //     final currentState = state as NewInProductsLoaded;
  //     final sortedProducts = [...currentState.products];
  //
  //     sortedProducts.sort((a, b) {
  //       final priceA = a.actualPrice; // Ensure it's numeric (double or int)
  //       final priceB = b.actualPrice;
  //       return event.sortOrder == SortOrder.lowToHigh
  //           ? priceA.compareTo(priceB) // Low to high
  //           : priceB.compareTo(priceA); // High to low
  //     });
  //
  //     emit(NewInProductsLoaded(sortedProducts));
  //   }
  // }

  void _onSortProducts(SortProductsEvent event, Emitter<NewInProductsState> emit) {
    if (state is NewInProductsLoaded) {
      final currentState = state as NewInProductsLoaded;
      final sortedProducts = [...currentState.products];

      sortedProducts.sort((a, b) {
        if (event.sortOrder == SortOrder.lowToHigh) {
          return a.actualPrice.compareTo(b.actualPrice);
        } else if (event.sortOrder == SortOrder.highToLow) {
          return b.actualPrice.compareTo(a.actualPrice);
        } else if (event.sortOrder == SortOrder.latest) {
          // Convert prod_en_id to int for proper numerical sorting
          final idA = int.tryParse(a.prod_en_id) ?? 0;
          final idB = int.tryParse(b.prod_en_id) ?? 0;
          return idB.compareTo(idA); // Latest = highest ID first
        }
        return 0;
      });

      emit(NewInProductsLoaded(sortedProducts));
    }
  }


}
// class NewInProductsBloc extends Bloc<NewInProductsEvent, NewInProductsState> {
//   final ProductRepository productRepository;
//   final String subcategory;
//   final List<Map<String, dynamic>>? selectedCategories;
//
//   NewInProductsBloc({
//     required this.productRepository,
//     required this.subcategory,
//     this.selectedCategories,
//   }) : super(NewInProductsInitial()) {
//     on<FetchProductsEvent>(_onFetchProducts);
//     on<SortProductsEvent>(_onSortProducts);
//   }
//
//   Future<void> _onFetchProducts(FetchProductsEvent event, Emitter<NewInProductsState> emit) async {
//     emit(NewInProductsLoading());
//
//     try {
//       final allProducts = <Product>[];
//
//       // Get API URLs for the selected subcategories (await the result)
//       final apiUrls = await ApiConstants.getApiUrlForSubcategory(subcategory);  // Add await here
//       print('🔗 API Called for "$subcategory": $apiUrls');
//
//       // If a single API URL is returned (string), call that API
//       if (apiUrls is String) {
//         print('📦 Fetching from: $apiUrls');
//         final products = await productRepository.fetchProductsBySubcategory(apiUrls);
//         allProducts.addAll(products);
//       }
//       // If multiple API URLs are returned (list), loop through and call each API
//       else if (apiUrls is List<String>) {
//         for (var url in apiUrls) {
//           print('📦 Fetching from: $url');
//           final products = await productRepository.fetchProductsBySubcategory(url);
//           allProducts.addAll(products);
//         }
//       }
//
//       emit(NewInProductsLoaded(allProducts));
//
//     } catch (e) {
//       print("❌ Error in _onFetchProducts: $e");
//       emit(NewInProductsError(message: "Failed to load products"));
//     }
//   }
//
//   // Future<void> _onFetchProducts(FetchProductsEvent event, Emitter<NewInProductsState> emit) async {
//   //   emit(NewInProductsLoading());
//   //
//   //   try {
//   //     final allProducts = <Product>[];
//   //
//   //     // Get API URLs for the selected subcategories
//   //     final apiUrls = ApiConstants.getApiUrlForSubcategory(subcategory);
//   //     print('🔗 API Called for "$subcategory": $apiUrls');
//   //
//   //     // If a single API URL is returned (string), call that API
//   //     if (apiUrls is String) {
//   //       print('📦 Fetching from: $apiUrls');
//   //       final products = await productRepository.fetchProductsBySubcategory(apiUrls);
//   //       allProducts.addAll(products);
//   //     }
//   //     // If multiple API URLs are returned (list), loop through and call each API
//   //     else if (apiUrls is List<String>) {
//   //       for (var url in apiUrls) {
//   //         print('📦 Fetching from: $url');
//   //         final products = await productRepository.fetchProductsBySubcategory(url);
//   //         allProducts.addAll(products);
//   //       }
//   //     }
//   //
//   //     emit(NewInProductsLoaded(allProducts));
//   //
//   //   } catch (e) {
//   //     print("❌ Error in _onFetchProducts: $e");
//   //     emit(NewInProductsError(message: "Failed to load products"));
//   //   }
//   // }
//
//   // Future<void> _onFetchProducts(
//   //     FetchProductsEvent event, Emitter<NewInProductsState> emit) async {
//   //   emit(NewInProductsLoading());
//   //
//   //   try {
//   //     final allProducts = <Product>[];
//   //
//   //     // Case 1: Filtered categories
//   //     if (subcategory.toLowerCase() == "filtered" && selectedCategories != null) {
//   //       final subcategoryNames = selectedCategories!
//   //           .expand((e) => e['subCategory']
//   //           .toString()
//   //           .toLowerCase()
//   //           .split(',')
//   //           .map((s) => s.trim()))
//   //           .toSet()
//   //           .toList();
//   //
//   //       for (var sub in subcategoryNames) {
//   //         final url = ApiConstants.getApiUrlForSubcategory(sub);
//   //         print('🔗 API Called for "$sub": $url');
//   //
//   //         if (url == null || url.isEmpty) {
//   //           print('🚫 No API available for "$sub"');
//   //           continue;
//   //         }
//   //
//   //         final products = await productRepository.fetchProductsBySubcategory(sub);
//   //         allProducts.addAll(products);
//   //       }
//   //
//   //       emit(NewInProductsLoaded(allProducts));
//   //     }
//   //
//   //     // Case 2: Single or comma-separated subcategories like "Contemporary, Ethnic"
//   //     else {
//   //       final subcategoryNames = subcategory
//   //           .toLowerCase()
//   //           .split(',')
//   //           .map((s) => s.trim())
//   //           .where((s) => s.isNotEmpty)
//   //           .toSet()
//   //           .toList();
//   //
//   //       for (var sub in subcategoryNames) {
//   //         final url = ApiConstants.getApiUrlForSubcategory(sub);
//   //         print('🔗 API Called for "$sub": $url');
//   //
//   //         if (url == null || url.isEmpty) {
//   //           print('🚫 No API available for "$sub"');
//   //           continue;
//   //         }
//   //
//   //         print('📦 Fetching from: $url');
//   //         final products = await productRepository.fetchProductsBySubcategory(sub);
//   //         allProducts.addAll(products);
//   //       }
//   //
//   //       emit(NewInProductsLoaded(allProducts));
//   //     }
//   //
//   //   } catch (e) {
//   //     print("❌ Error in _onFetchProducts: $e");
//   //     emit(NewInProductsError(message: "Failed to load products"));
//   //   }
//   // }
//
//
//
//   // Future<void> _onFetchProducts(FetchProductsEvent event,
//   //     Emitter<NewInProductsState> emit) async {
//   //   emit(NewInProductsLoading());
//   //
//   //   try {
//   //     if (subcategory.toLowerCase() == "filtered" &&
//   //         selectedCategories != null) {
//   //       final allProducts = <Product>[];
//   //       // final subcategoryNames = selectedCategories!
//   //       //     .map((e) => e['subCategory'].toString().toLowerCase())
//   //       //     .toList();
//   //       final subcategoryNames = selectedCategories!
//   //           .expand((e) => e['subCategory']
//   //           .toString()
//   //           .toLowerCase()
//   //           .split(',')
//   //           .map((s) => s.trim()))
//   //           .toList();
//   //
//   //
//   //       // for (var sub in subcategoryNames) {
//   //
//   //       for (var category in selectedCategories!) {
//   //         final sub = category['subCategory']?.toString().toLowerCase();
//   //         if (sub == null) continue;
//   //
//   //         final url = ApiConstants.getApiUrlForSubcategory(sub);
//   //         print('Api>>:$url');
//   //
//   //         print('🔗 API Called for "$sub": $url');
//   //
//   //         if (url == null || url.isEmpty) {
//   //           print('🚫 No API available for $sub');
//   //           continue;
//   //         }
//   //
//   //         final products = await productRepository.fetchProductsBySubcategory(
//   //             sub);
//   //         allProducts.addAll(products);
//   //       }
//   //
//   //       // for (var item in selectedCategories!) {
//   //       //   final sub = item["subCategory"];
//   //       //   if (sub != null) {
//   //       //     final url = ApiConstants.getApiUrlForSubcategory(sub.toLowerCase());
//   //       //     print('🔗 API Called for "$sub": $url');
//   //       //     final products = await productRepository.fetchProductsBySubcategory(sub.toLowerCase());
//   //       //     allProducts.addAll(products);
//   //       //   }
//   //       // }
//   //
//   //       emit(NewInProductsLoaded(allProducts));
//   //     } else {
//   //       final endpoint = ApiConstants.getApiKeyForSubcategory(
//   //           subcategory.toLowerCase());
//   //       print('🔗 API Called for "$subcategory": $endpoint');
//   //
//   //       if (endpoint == null) {
//   //         emit(NewInProductsError(message: "No API available for $subcategory"));
//   //         return;
//   //       }
//   //
//   //
//   //       final products = await productRepository.fetchProductsBySubcategory(
//   //           subcategory.toLowerCase());
//   //
//   //       emit(NewInProductsLoaded(products));
//   //     }
//   //   } catch (e) {
//   //     print("❌ Error in _onFetchProducts: $e");
//   //     emit(NewInProductsError(message: "Failed to load products"));
//   //   }
//   // }
//
//
//   void _onSortProducts(SortProductsEvent event,
//       Emitter<NewInProductsState> emit) {
//     if (state is NewInProductsLoaded) {
//       final currentState = state as NewInProductsLoaded;
//       final sortedProducts = [...currentState.products];
//
//       sortedProducts.sort((a, b) {
//         final priceA = a.actualPrice; // Ensure it's numeric (double or int)
//         final priceB = b.actualPrice;
//         return event.sortOrder == SortOrder.lowToHigh
//             ? priceA.compareTo(priceB) // Low to high
//             : priceB.compareTo(priceA); // High to low
//       });
//
//       emit(NewInProductsLoaded(sortedProducts));
//     }
//   }
//
// }
// class NewInProductsBloc extends Bloc<NewInProductsEvent, NewInProductsState> {
//   final ProductRepository productRepository;
//   final String subcategory;
//
//   NewInProductsBloc({required this.productRepository, required this.subcategory})
//       : super(NewInProductsInitial()) {
//     on<FetchProductsEvent>(_onFetchProducts);
//     on<SortProductsEvent>(_onSortProducts);
//   }
//   Future<void> _onFetchProducts(FetchProductsEvent event, Emitter<NewInProductsState> emit) async {
//     emit(NewInProductsLoading());
//     try {
//       final endpoint = ApiConstants.getApiKeyForSubcategory(subcategory.toLowerCase());
//       print('🔗 API Called for "$subcategory": $endpoint');
//
//       if (endpoint == null) {
//         emit(NewInProductsError("No API available for $subcategory"));
//         return;
//       }
//
//       final products = await productRepository.fetchProductsBySubcategory(subcategory.toLowerCase());
//       emit(NewInProductsLoaded(products));
//     } catch (e) {
//       emit(NewInProductsError("Failed to load products"));
//     }
//   }
//
//   // Future<void> _onFetchProducts(FetchProductsEvent event, Emitter<NewInProductsState> emit) async {
//   //   emit(NewInProductsLoading());
//   //   try {
//   //     final products = await productRepository.fetchProductsBySubcategory(subcategory);
//   //     emit(NewInProductsLoaded(products));
//   //   } catch (e) {
//   //     emit(NewInProductsError("Failed to load products"));
//   //   }
//   // }
//
//   void _onSortProducts(SortProductsEvent event, Emitter<NewInProductsState> emit) {
//     if (state is NewInProductsLoaded) {
//       final currentState = state as NewInProductsLoaded;
//       final sortedProducts = [...currentState.products];
//       sortedProducts.sort((a, b) {
//         final priceA = a.actualPrice;
//         final priceB = b.actualPrice;
//         return event.sortOrder == SortOrder.lowToHigh
//             ? priceA.compareTo(priceB)
//             : priceB.compareTo(priceA);
//       });
//       emit(NewInProductsLoaded(sortedProducts));
//     }
//   }
//
// }
