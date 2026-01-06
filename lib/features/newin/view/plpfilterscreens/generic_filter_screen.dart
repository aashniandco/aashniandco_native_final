
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/bloc/currency_bloc.dart';
import '../../../auth/bloc/currency_state.dart';
import '../../../categories/model/filter_model.dart';
import '../../../categories/repository/api_service.dart';
import '../../../categories/view/filtered_products_screen.dart';
import '../../../designer_details.dart';

import 'package:intl/intl.dart';

class GenericFilterScreen extends StatefulWidget {
  final String categoryId;
  final String filterType;
  final String appBarTitle;
  final List<FilterItem> preSelectedItems;

  const GenericFilterScreen({
    Key? key,
    required this.categoryId,
    required this.filterType,
    required this.appBarTitle,
    this.preSelectedItems = const [],
  }) : super(key: key);

  @override
  State<GenericFilterScreen> createState() => _GenericFilterScreenState();
}

class _GenericFilterScreenState extends State<GenericFilterScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  final FocusNode _minFocusNode = FocusNode();
  final FocusNode _maxFocusNode = FocusNode();

  static const double _pivotValue = 0.5;
  static const double _pivotPrice = 100000;

  // --- Standard Filter Variables ---
  List<FilterItem> _allItems = [];
  List<FilterItem> _displayedItems = [];

  // --- Price Specific Variables ---
  bool get _isPriceMode => widget.filterType == 'price';
  double _minDataValue = 0;
  double _maxDataValue = 1000;
  RangeValues _currentRangeValues = const RangeValues(0.0, 1.0);

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _minFocusNode.dispose(); // Add this
    _maxFocusNode.dispose(); // Add this
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      if (_isPriceMode) {
        final priceData = await _apiService.fetchPriceRange(widget.categoryId);
        setState(() {
          _minDataValue = priceData['min']!;
          _maxDataValue = priceData['max']!;

          if (widget.preSelectedItems.isNotEmpty) {
            final parts = widget.preSelectedItems.first.id.split('-');
            if (parts.length == 2) {
              double start = double.tryParse(parts[0]) ?? _minDataValue;
              double end = double.tryParse(parts[1]) ?? _maxDataValue;

              // FIX: Convert real prices to 0.0 - 1.0 scale
              _currentRangeValues = RangeValues(
                  _priceToNormalized(start),
                  _priceToNormalized(end)
              );
            }
          } else {
            // FIX: Default to full range (0.0 to 1.0)
            _currentRangeValues = const RangeValues(0.0, 1.0);
          }
          _isLoading = false;
        });
      }
      else {
        // 2. Fetch Standard Data (Colors, Sizes, etc.)
        final items = await _apiService.fetchGenericFilter(
          categoryId: widget.categoryId,
          filterType: widget.filterType,
        );
        setState(() {
          _allItems = items;
          _syncSelections();
          _displayedItems = List.from(_allItems);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  double _normalizedToPrice(double t) {
    if (t <= _pivotValue) {
      // 0.0 to 0.5 maps to 0 to 1 Lakh
      return (t / _pivotValue) * _pivotPrice;
    } else {
      // 0.5 to 1.0 maps to 1 Lakh to maxDataValue
      return _pivotPrice + ((t - _pivotValue) / (1 - _pivotValue)) * (_maxDataValue - _pivotPrice);
    }
  }

  double _priceToNormalized(double price) {
    if (price <= _pivotPrice) {
      return (price / _pivotPrice) * _pivotValue;
    } else {
      return _pivotValue + ((price - _pivotPrice) / (_maxDataValue - _pivotPrice)) * (1 - _pivotValue);
    }
  }

  void _syncSelections() {
    final selectedIds = widget.preSelectedItems.map((e) => e.id).toSet();
    for (var item in _allItems) {
      if (selectedIds.contains(item.id)) item.isSelected = true;
      for (var child in item.children) {
        if (selectedIds.contains(child.id)) {
          child.isSelected = true;
          item.isExpanded = true;
        }
      }
    }
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedItems = List.from(_allItems);
      } else {
        _displayedItems = _allItems.where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  void _clearSelection() {
    setState(() {
      if (_isPriceMode) {
        _currentRangeValues = RangeValues(0.0, 1.0);
      } else {
        for (var item in _allItems) {
          item.isSelected = false;
          for (var child in item.children) child.isSelected = false;
        }
        _searchController.clear();
        _filterList('');
      }
    });
  }

  void _onDonePressed() {
    List<FilterItem> selectedItems = [];

    if (_isPriceMode) {
      // 1. Get Currency Data from Bloc
      final currencyState = context.read<CurrencyBloc>().state;
      String displaySymbol = '₹';
      double currentRate = 1.0;

      if (currencyState is CurrencyLoaded) {
        displaySymbol = currencyState.selectedSymbol;
        currentRate = currencyState.selectedRate.rate;
      }

      // 2. Setup Formatter
      final NumberFormat priceFormatter = NumberFormat.currency(
        symbol: displaySymbol,
        decimalDigits: 0,
        locale: displaySymbol == '₹'
            ? 'en_IN'
            : displaySymbol == '£'
            ? 'en_GB'
            : 'en_US',
      );

      // 3. Get Base Prices (INR) for the API ID
      double finalBaseMin = _normalizedToPrice(_currentRangeValues.start);
      double finalBaseMax = _normalizedToPrice(_currentRangeValues.end);

      // 4. Get Display Prices (Converted) for the UI Name
      double displayMin = finalBaseMin * currentRate;
      double displayMax = finalBaseMax * currentRate;

      // Create the string: e.g., "₹1,000 - ₹5,000" or "$12 - $60"
      String formattedPriceRange = "${priceFormatter.format(displayMin)} - ${priceFormatter.format(displayMax)}";

      // Only add if user actually changed the range or if you want it always
      selectedItems.add(FilterItem(
        // The ID remains in base currency (INR) so your API logic stays consistent
          id: "${finalBaseMin.toInt()}-${finalBaseMax.toInt()}",
          name: formattedPriceRange,
          isSelected: true,
          children: []
      ));
    } else {
      // Standard logic for checkboxes
      for (var item in _allItems) {
        if (item.isSelected) selectedItems.add(item);
        for (var child in item.children) {
          if (child.isSelected) selectedItems.add(child);
        }
      }
    }

    Navigator.pop(context, selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = context.watch<CurrencyBloc>().state;
    String displaySymbol = '₹';
    double currentRate = 1.0;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      currentRate = currencyState.selectedRate.rate;
    }

    final NumberFormat priceFormatter = NumberFormat.currency(
      symbol: displaySymbol,
      decimalDigits: 0,
      locale: displaySymbol == '₹'
          ? 'en_IN'
          : displaySymbol == '£'
          ? 'en_GB'
          : 'en_US',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _onDonePressed,
        ),
        title: Text(
          widget.appBarTitle.toUpperCase(),
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _clearSelection,
            child: const Text("Clear All", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : Column(
        children: [
          // Search Bar (Only for non-price filters)
          if (!_isPriceMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterList,
                decoration: InputDecoration(
                  hintText: "Search ${widget.appBarTitle}...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

          // Main Content
          Expanded(
            child: _isPriceMode
                ? _buildPriceSlider(currentRate, displaySymbol, priceFormatter)
                : _buildCheckboxList(),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                ),
                onPressed: _onDonePressed,
                child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateTextControllers(double start, double end) {
    _minController.text = start.toInt().toString();
    _maxController.text = end.toInt().toString();
  }

  void _onManualInputChange(double rate) {
    // 1. Get the value user typed (in selected currency)
    double displayMin = double.tryParse(_minController.text) ?? (_minDataValue * rate);
    double displayMax = double.tryParse(_maxController.text) ?? (_maxDataValue * rate);

    // 2. Convert back to base currency (INR) for internal logic
    double baseMin = displayMin / rate;
    double baseMax = displayMax / rate;

    // Clamp values against base data
    if (baseMin < _minDataValue) baseMin = _minDataValue;
    if (baseMax > _maxDataValue) baseMax = _maxDataValue;
    if (baseMin > baseMax) baseMin = baseMax;

    setState(() {
      _currentRangeValues = RangeValues(
        _priceToNormalized(baseMin),
        _priceToNormalized(baseMax),
      );
    });
  }

  Widget _buildPriceSlider(double rate, String symbol, NumberFormat formatter) {
    // Internal values are always base currency (INR)
    // We convert to display values using the rate
    double baseMinPrice = _normalizedToPrice(_currentRangeValues.start);
    double baseMaxPrice = _normalizedToPrice(_currentRangeValues.end);

    double displayMin = baseMinPrice * rate;
    double displayMax = baseMaxPrice * rate;

    // Update controllers if not being edited
    if (!_minFocusNode.hasFocus) {
      _minController.text = displayMin.toInt().toString();
    }
    if (!_maxFocusNode.hasFocus) {
      _maxController.text = displayMax.toInt().toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minController,
                  focusNode: _minFocusNode,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Min Price",
                    prefixText: "$symbol ",
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) => _onManualInputChange(rate),
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("-")),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  focusNode: _maxFocusNode,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Max Price",
                    prefixText: "$symbol ",
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) => _onManualInputChange(rate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: RangeSlider(
              values: _currentRangeValues,
              min: 0.0,
              max: 1.0,
              activeColor: Colors.black,
              inactiveColor: Colors.grey[300],
              labels: RangeLabels(
                formatter.format(displayMin),
                formatter.format(displayMax),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
          ),

          // Range Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatter.format(_minDataValue * rate)),
                // Show converted pivot hint
                // Text(
                //   "Mid: ${formatter.format(_pivotPrice * rate)}",
                //   style: const TextStyle(color: Colors.blue, fontSize: 10),
                // ),
                Text(formatter.format(_maxDataValue * rate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  //2/1/2026
  // Widget _buildPriceSlider() {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Text(
  //         "₹${_currentRangeValues.start.toInt()} - ₹${_currentRangeValues.end.toInt()}",
  //         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 20),
  //       RangeSlider(
  //         values: _currentRangeValues,
  //         min: _minDataValue,
  //         max: _maxDataValue,
  //         divisions: 100, // Optional: makes slider snap
  //         activeColor: Colors.black,
  //         inactiveColor: Colors.grey[300],
  //         labels: RangeLabels(
  //           "₹${_currentRangeValues.start.toInt()}",
  //           "₹${_currentRangeValues.end.toInt()}",
  //         ),
  //         onChanged: (RangeValues values) {
  //           setState(() {
  //             _currentRangeValues = values;
  //           });
  //         },
  //       ),
  //       const SizedBox(height: 10),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text("Min: ₹${_minDataValue.toInt()}", style: const TextStyle(color: Colors.grey)),
  //             Text("Max: ₹${_maxDataValue.toInt()}", style: const TextStyle(color: Colors.grey)),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildCheckboxList() {
    if (_displayedItems.isEmpty) return const Center(child: Text("No items found"));

    return ListView.separated(
      itemCount: _displayedItems.length,
      separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final item = _displayedItems[index];
        return _buildCheckboxTile(item);
      },
    );
  }

  Widget _buildCheckboxTile(FilterItem item) {
    if (item.children.isNotEmpty) {
      // Case: Parent with children (ExpansionTile)
      return ExpansionTile(
        // Keep the expansion arrow on the right, checkbox on the left
        controlAffinity: ListTileControlAffinity.trailing,
        title: Text(item.name, style: const TextStyle(fontSize: 15)),
        leading: Checkbox(
          activeColor: Colors.black,
          value: item.isSelected,
          onChanged: (bool? value) {
            setState(() {
              item.isSelected = value!;
              // Logic: if parent is selected, you might want to deselect children
              // or vice versa depending on your business logic.
              for (var child in item.children) child.isSelected = false;
            });
          },
        ),
        children: item.children.map((child) {
          return ListTile(
            contentPadding: const EdgeInsets.only(left: 40, right: 20),
            title: Text(child.name, style: const TextStyle(fontSize: 14)),
            leading: Checkbox(
              activeColor: Colors.black,
              value: child.isSelected,
              onChanged: (bool? value) {
                setState(() {
                  child.isSelected = value!;
                  if (value) item.isSelected = false;
                });
              },
            ),
            onTap: () {
              setState(() {
                child.isSelected = !child.isSelected;
                if (child.isSelected) item.isSelected = false;
              });
            },
          );
        }).toList(),
      );
    } else {
      // Case: Parent WITHOUT children (Standard ListTile)
      // Updated to match the look of the ExpansionTile leading checkbox
      return ListTile(
        onTap: () {
          setState(() {
            item.isSelected = !item.isSelected;
          });
        },
        leading: Checkbox(
          activeColor: Colors.black,
          value: item.isSelected,
          onChanged: (bool? value) {
            setState(() {
              item.isSelected = value!;
            });
          },
        ),
        title: Text(item.name, style: const TextStyle(fontSize: 15)),
      );
    }
  }
//2/1/2026
// Widget _buildCheckboxTile(FilterItem item) {
//   if (item.children.isNotEmpty) {
//     return ExpansionTile(
//       title: Text(item.name, style: const TextStyle(fontSize: 15)),
//       leading: Checkbox(
//         activeColor: Colors.black,
//         value: item.isSelected,
//         onChanged: (bool? value) {
//           setState(() {
//             item.isSelected = value!;
//             for (var child in item.children) child.isSelected = false;
//           });
//         },
//       ),
//       children: item.children.map((child) {
//         return ListTile(
//           contentPadding: const EdgeInsets.only(left: 40, right: 20),
//           title: Text(child.name, style: const TextStyle(fontSize: 14)),
//           leading: Checkbox(
//             activeColor: Colors.black,
//             value: child.isSelected,
//             onChanged: (bool? value) {
//               setState(() {
//                 child.isSelected = value!;
//                 if (value) item.isSelected = false;
//               });
//             },
//           ),
//         );
//       }).toList(),
//     );
//   } else {
//     return ListTile(
//       onTap: () {
//         setState(() {
//           item.isSelected = !item.isSelected;
//         });
//       },
//       title: Text(item.name, style: const TextStyle(fontSize: 15)),
//       trailing: item.isSelected ? const Icon(Icons.check, color: Colors.black) : null,
//     );
//   }
// }
}

//10F
// class GenericFilterScreen extends StatefulWidget {
//   final String categoryId;
//   final String filterType;
//   final String appBarTitle;
//   final List<FilterItem> preSelectedItems;
//
//   const GenericFilterScreen({
//     Key? key,
//     required this.categoryId,
//     required this.filterType,
//     required this.appBarTitle,
//     this.preSelectedItems = const [],
//   }) : super(key: key);
//
//   @override
//   State<GenericFilterScreen> createState() => _GenericFilterScreenState();
// }
//
// class _GenericFilterScreenState extends State<GenericFilterScreen> {
//   final ApiService _apiService = ApiService();
//   final TextEditingController _searchController = TextEditingController();
//
//   final TextEditingController _minController = TextEditingController();
//   final TextEditingController _maxController = TextEditingController();
//
//   final FocusNode _minFocusNode = FocusNode();
//   final FocusNode _maxFocusNode = FocusNode();
//
//   static const double _pivotValue = 0.5;
//   static const double _pivotPrice = 100000;
//
//   // --- Standard Filter Variables ---
//   List<FilterItem> _allItems = [];
//   List<FilterItem> _displayedItems = [];
//
//   static const List<String> _womenClothingPriority = [
//     "Kurta Sets",
//     "Lehengas",
//     "Sarees",
//     "Anarkalis",
//     "Sharara Sets",
//     "Kaftans",
//     "Dresses",
//     "Co-ords",
//     "Jackets",
//     "Gowns",
//   ];
//
//   // --- Price Specific Variables ---
//   bool get _isPriceMode => widget.filterType == 'price';
//   double _minDataValue = 0;
//   double _maxDataValue = 1000;
//   RangeValues _currentRangeValues = const RangeValues(0.0, 1.0);
//
//   bool _isLoading = true;
//   String _errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }
//
//   @override
//   void dispose() {
//     _minController.dispose();
//     _maxController.dispose();
//     _minFocusNode.dispose(); // Add this
//     _maxFocusNode.dispose(); // Add this
//     super.dispose();
//   }
//
//   Future<void> _fetchData() async {
//     try {
//       if (_isPriceMode) {
//         final priceData = await _apiService.fetchPriceRange(widget.categoryId);
//         setState(() {
//           _minDataValue = priceData['min']!;
//           _maxDataValue = priceData['max']!;
//
//           if (widget.preSelectedItems.isNotEmpty) {
//             final parts = widget.preSelectedItems.first.id.split('-');
//             if (parts.length == 2) {
//               double start = double.tryParse(parts[0]) ?? _minDataValue;
//               double end = double.tryParse(parts[1]) ?? _maxDataValue;
//
//               // FIX: Convert real prices to 0.0 - 1.0 scale
//               _currentRangeValues = RangeValues(
//                   _priceToNormalized(start),
//                   _priceToNormalized(end)
//               );
//             }
//           } else {
//             // FIX: Default to full range (0.0 to 1.0)
//             _currentRangeValues = const RangeValues(0.0, 1.0);
//           }
//           _isLoading = false;
//         });
//       }
//       else {
//         // 2. Fetch Standard Data (Colors, Sizes, etc.)
//         final items = await _apiService.fetchGenericFilter(
//           categoryId: widget.categoryId,
//           filterType: widget.filterType,
//         );
//         setState(() {
//           _allItems = items;
//
//           if (widget.categoryId == '3374') {
//             _allItems.sort((a, b) {
//               // Get index in priority list (-1 if not found)
//               int indexA = _womenClothingPriority.indexOf(a.name);
//               int indexB = _womenClothingPriority.indexOf(b.name);
//
//               // If both items are in the priority list, sort by their priority index
//               if (indexA != -1 && indexB != -1) {
//                 return indexA.compareTo(indexB);
//               }
//
//               // If only A is in the priority list, A comes first
//               if (indexA != -1) return -1;
//
//               // If only B is in the priority list, B comes first
//               if (indexB != -1) return 1;
//
//               // If neither is in the priority list, sort alphabetically
//               return a.name.toLowerCase().compareTo(b.name.toLowerCase());
//             });
//           }
//           _syncSelections();
//           _displayedItems = List.from(_allItems);
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   double _normalizedToPrice(double t) {
//     if (t <= _pivotValue) {
//       // 0.0 to 0.5 maps to 0 to 1 Lakh
//       return (t / _pivotValue) * _pivotPrice;
//     } else {
//       // 0.5 to 1.0 maps to 1 Lakh to maxDataValue
//       return _pivotPrice + ((t - _pivotValue) / (1 - _pivotValue)) * (_maxDataValue - _pivotPrice);
//     }
//   }
//
//   double _priceToNormalized(double price) {
//     if (price <= _pivotPrice) {
//       return (price / _pivotPrice) * _pivotValue;
//     } else {
//       return _pivotValue + ((price - _pivotPrice) / (_maxDataValue - _pivotPrice)) * (1 - _pivotValue);
//     }
//   }
//
//   void _syncSelections() {
//     final selectedIds = widget.preSelectedItems.map((e) => e.id).toSet();
//     for (var item in _allItems) {
//       if (selectedIds.contains(item.id)) item.isSelected = true;
//       for (var child in item.children) {
//         if (selectedIds.contains(child.id)) {
//           child.isSelected = true;
//           item.isExpanded = true;
//         }
//       }
//     }
//   }
//
//   void _filterList(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _displayedItems = List.from(_allItems);
//       } else {
//         _displayedItems = _allItems.where((item) =>
//             item.name.toLowerCase().contains(query.toLowerCase())).toList();
//       }
//     });
//   }
//
//   void _clearSelection() {
//     setState(() {
//       if (_isPriceMode) {
//         _currentRangeValues = RangeValues(0.0, 1.0);
//       } else {
//         for (var item in _allItems) {
//           item.isSelected = false;
//           for (var child in item.children) child.isSelected = false;
//         }
//         _searchController.clear();
//         _filterList('');
//       }
//     });
//   }
//
//   void _onDonePressed() {
//     List<FilterItem> selectedItems = [];
//
//     if (_isPriceMode) {
//       // 1. Get Currency Data from Bloc
//       final currencyState = context.read<CurrencyBloc>().state;
//       String displaySymbol = '₹';
//       double currentRate = 1.0;
//
//       if (currencyState is CurrencyLoaded) {
//         displaySymbol = currencyState.selectedSymbol;
//         currentRate = currencyState.selectedRate.rate;
//       }
//
//       // 2. Setup Formatter
//       final NumberFormat priceFormatter = NumberFormat.currency(
//         symbol: displaySymbol,
//         decimalDigits: 0,
//         locale: displaySymbol == '₹'
//             ? 'en_IN'
//             : displaySymbol == '£'
//             ? 'en_GB'
//             : 'en_US',
//       );
//
//       // 3. Get Base Prices (INR) for the API ID
//       double finalBaseMin = _normalizedToPrice(_currentRangeValues.start);
//       double finalBaseMax = _normalizedToPrice(_currentRangeValues.end);
//
//       // 4. Get Display Prices (Converted) for the UI Name
//       double displayMin = finalBaseMin * currentRate;
//       double displayMax = finalBaseMax * currentRate;
//
//       // Create the string: e.g., "₹1,000 - ₹5,000" or "$12 - $60"
//       String formattedPriceRange = "${priceFormatter.format(displayMin)} - ${priceFormatter.format(displayMax)}";
//
//       // Only add if user actually changed the range or if you want it always
//       selectedItems.add(FilterItem(
//         // The ID remains in base currency (INR) so your API logic stays consistent
//           id: "${finalBaseMin.toInt()}-${finalBaseMax.toInt()}",
//           name: formattedPriceRange,
//           isSelected: true,
//           children: []
//       ));
//     } else {
//       // Standard logic for checkboxes
//       for (var item in _allItems) {
//         if (item.isSelected) selectedItems.add(item);
//         for (var child in item.children) {
//           if (child.isSelected) selectedItems.add(child);
//         }
//       }
//     }
//
//     Navigator.pop(context, selectedItems);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currencyState = context.watch<CurrencyBloc>().state;
//     String displaySymbol = '₹';
//     double currentRate = 1.0;
//
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       currentRate = currencyState.selectedRate.rate;
//     }
//
//     final NumberFormat priceFormatter = NumberFormat.currency(
//       symbol: displaySymbol,
//       decimalDigits: 0,
//       locale: displaySymbol == '₹'
//           ? 'en_IN'
//           : displaySymbol == '£'
//           ? 'en_GB'
//           : 'en_US',
//     );
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: _onDonePressed,
//         ),
//         title: Text(
//           widget.appBarTitle.toUpperCase(),
//           style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           TextButton(
//             onPressed: _clearSelection,
//             child: const Text("Clear All", style: TextStyle(color: Colors.grey)),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage.isNotEmpty
//           ? Center(child: Text(_errorMessage))
//           : Column(
//         children: [
//           // Search Bar (Only for non-price filters)
//           if (!_isPriceMode)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: const BoxDecoration(
//                 border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: _filterList,
//                 decoration: InputDecoration(
//                   hintText: "Search ${widget.appBarTitle}...",
//                   prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),
//
//           // Main Content
//           Expanded(
//             child: _isPriceMode
//                 ? _buildPriceSlider(currentRate, displaySymbol, priceFormatter)
//                 : _buildCheckboxList(),
//           ),
//
//           // Apply Button
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
//                 ),
//                 onPressed: _onDonePressed,
//                 child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _updateTextControllers(double start, double end) {
//     _minController.text = start.toInt().toString();
//     _maxController.text = end.toInt().toString();
//   }
//
//   void _onManualInputChange(double rate) {
//     // 1. Get the value user typed (in selected currency)
//     double displayMin = double.tryParse(_minController.text) ?? (_minDataValue * rate);
//     double displayMax = double.tryParse(_maxController.text) ?? (_maxDataValue * rate);
//
//     // 2. Convert back to base currency (INR) for internal logic
//     double baseMin = displayMin / rate;
//     double baseMax = displayMax / rate;
//
//     // Clamp values against base data
//     if (baseMin < _minDataValue) baseMin = _minDataValue;
//     if (baseMax > _maxDataValue) baseMax = _maxDataValue;
//     if (baseMin > baseMax) baseMin = baseMax;
//
//     setState(() {
//       _currentRangeValues = RangeValues(
//         _priceToNormalized(baseMin),
//         _priceToNormalized(baseMax),
//       );
//     });
//   }
//
//   Widget _buildPriceSlider(double rate, String symbol, NumberFormat formatter) {
//     // Internal values are always base currency (INR)
//     // We convert to display values using the rate
//     double baseMinPrice = _normalizedToPrice(_currentRangeValues.start);
//     double baseMaxPrice = _normalizedToPrice(_currentRangeValues.end);
//
//     double displayMin = baseMinPrice * rate;
//     double displayMax = baseMaxPrice * rate;
//
//     // Update controllers if not being edited
//     if (!_minFocusNode.hasFocus) {
//       _minController.text = displayMin.toInt().toString();
//     }
//     if (!_maxFocusNode.hasFocus) {
//       _maxController.text = displayMax.toInt().toString();
//     }
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _minController,
//                   focusNode: _minFocusNode,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: "Min Price",
//                     prefixText: "$symbol ",
//                     border: const OutlineInputBorder(),
//                   ),
//                   onChanged: (val) => _onManualInputChange(rate),
//                 ),
//               ),
//               const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("-")),
//               Expanded(
//                 child: TextField(
//                   controller: _maxController,
//                   focusNode: _maxFocusNode,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: "Max Price",
//                     prefixText: "$symbol ",
//                     border: const OutlineInputBorder(),
//                   ),
//                   onChanged: (val) => _onManualInputChange(rate),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 30),
//
//           SliderTheme(
//             data: SliderTheme.of(context).copyWith(
//               showValueIndicator: ShowValueIndicator.always,
//             ),
//             child: RangeSlider(
//               values: _currentRangeValues,
//               min: 0.0,
//               max: 1.0,
//               activeColor: Colors.black,
//               inactiveColor: Colors.grey[300],
//               labels: RangeLabels(
//                 formatter.format(displayMin),
//                 formatter.format(displayMax),
//               ),
//               onChanged: (RangeValues values) {
//                 setState(() {
//                   _currentRangeValues = values;
//                 });
//               },
//             ),
//           ),
//
//           // Range Labels
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(formatter.format(_minDataValue * rate)),
//                 // Show converted pivot hint
//                 Text(
//                   "Mid: ${formatter.format(_pivotPrice * rate)}",
//                   style: const TextStyle(color: Colors.blue, fontSize: 10),
//                 ),
//                 Text(formatter.format(_maxDataValue * rate)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   //2/1/2026
//   // Widget _buildPriceSlider() {
//   //   return Column(
//   //     mainAxisAlignment: MainAxisAlignment.center,
//   //     children: [
//   //       Text(
//   //         "₹${_currentRangeValues.start.toInt()} - ₹${_currentRangeValues.end.toInt()}",
//   //         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   //       ),
//   //       const SizedBox(height: 20),
//   //       RangeSlider(
//   //         values: _currentRangeValues,
//   //         min: _minDataValue,
//   //         max: _maxDataValue,
//   //         divisions: 100, // Optional: makes slider snap
//   //         activeColor: Colors.black,
//   //         inactiveColor: Colors.grey[300],
//   //         labels: RangeLabels(
//   //           "₹${_currentRangeValues.start.toInt()}",
//   //           "₹${_currentRangeValues.end.toInt()}",
//   //         ),
//   //         onChanged: (RangeValues values) {
//   //           setState(() {
//   //             _currentRangeValues = values;
//   //           });
//   //         },
//   //       ),
//   //       const SizedBox(height: 10),
//   //       Padding(
//   //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//   //         child: Row(
//   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //           children: [
//   //             Text("Min: ₹${_minDataValue.toInt()}", style: const TextStyle(color: Colors.grey)),
//   //             Text("Max: ₹${_maxDataValue.toInt()}", style: const TextStyle(color: Colors.grey)),
//   //           ],
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   Widget _buildCheckboxList() {
//     if (_displayedItems.isEmpty) return const Center(child: Text("No items found"));
//
//     return ListView.separated(
//       itemCount: _displayedItems.length,
//       separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 16),
//       itemBuilder: (context, index) {
//         final item = _displayedItems[index];
//         return _buildCheckboxTile(item);
//       },
//     );
//   }
//
//   Widget _buildCheckboxTile(FilterItem item) {
//     if (item.children.isNotEmpty) {
//       // Case: Parent with children (ExpansionTile)
//       return ExpansionTile(
//         // Keep the expansion arrow on the right, checkbox on the left
//         controlAffinity: ListTileControlAffinity.trailing,
//         title: Text(item.name, style: const TextStyle(fontSize: 15)),
//         leading: Checkbox(
//           activeColor: Colors.black,
//           value: item.isSelected,
//           onChanged: (bool? value) {
//             setState(() {
//               item.isSelected = value!;
//               // Logic: if parent is selected, you might want to deselect children
//               // or vice versa depending on your business logic.
//               for (var child in item.children) child.isSelected = false;
//             });
//           },
//         ),
//         children: item.children.map((child) {
//           return ListTile(
//             contentPadding: const EdgeInsets.only(left: 40, right: 20),
//             title: Text(child.name, style: const TextStyle(fontSize: 14)),
//             leading: Checkbox(
//               activeColor: Colors.black,
//               value: child.isSelected,
//               onChanged: (bool? value) {
//                 setState(() {
//                   child.isSelected = value!;
//                   if (value) item.isSelected = false;
//                 });
//               },
//             ),
//             onTap: () {
//               setState(() {
//                 child.isSelected = !child.isSelected;
//                 if (child.isSelected) item.isSelected = false;
//               });
//             },
//           );
//         }).toList(),
//       );
//     } else {
//       // Case: Parent WITHOUT children (Standard ListTile)
//       // Updated to match the look of the ExpansionTile leading checkbox
//       return ListTile(
//         onTap: () {
//           setState(() {
//             item.isSelected = !item.isSelected;
//           });
//         },
//         leading: Checkbox(
//           activeColor: Colors.black,
//           value: item.isSelected,
//           onChanged: (bool? value) {
//             setState(() {
//               item.isSelected = value!;
//             });
//           },
//         ),
//         title: Text(item.name, style: const TextStyle(fontSize: 15)),
//       );
//     }
//   }
//   //2/1/2026
//   // Widget _buildCheckboxTile(FilterItem item) {
//   //   if (item.children.isNotEmpty) {
//   //     return ExpansionTile(
//   //       title: Text(item.name, style: const TextStyle(fontSize: 15)),
//   //       leading: Checkbox(
//   //         activeColor: Colors.black,
//   //         value: item.isSelected,
//   //         onChanged: (bool? value) {
//   //           setState(() {
//   //             item.isSelected = value!;
//   //             for (var child in item.children) child.isSelected = false;
//   //           });
//   //         },
//   //       ),
//   //       children: item.children.map((child) {
//   //         return ListTile(
//   //           contentPadding: const EdgeInsets.only(left: 40, right: 20),
//   //           title: Text(child.name, style: const TextStyle(fontSize: 14)),
//   //           leading: Checkbox(
//   //             activeColor: Colors.black,
//   //             value: child.isSelected,
//   //             onChanged: (bool? value) {
//   //               setState(() {
//   //                 child.isSelected = value!;
//   //                 if (value) item.isSelected = false;
//   //               });
//   //             },
//   //           ),
//   //         );
//   //       }).toList(),
//   //     );
//   //   } else {
//   //     return ListTile(
//   //       onTap: () {
//   //         setState(() {
//   //           item.isSelected = !item.isSelected;
//   //         });
//   //       },
//   //       title: Text(item.name, style: const TextStyle(fontSize: 15)),
//   //       trailing: item.isSelected ? const Icon(Icons.check, color: Colors.black) : null,
//   //     );
//   //   }
//   // }
// }
//10/12/2025
// class GenericFilterScreen extends StatefulWidget {
//   final String categoryId;
//   final String filterType;
//   final String appBarTitle;
//   final List<FilterItem> preSelectedItems;
//
//   const GenericFilterScreen({
//     Key? key,
//     required this.categoryId,
//     required this.filterType,
//     required this.appBarTitle,
//     this.preSelectedItems = const [],
//   }) : super(key: key);
//
//   @override
//   State<GenericFilterScreen> createState() => _GenericFilterScreenState();
// }
//
// class _GenericFilterScreenState extends State<GenericFilterScreen> {
//   final ApiService _apiService = ApiService();
//   final TextEditingController _searchController = TextEditingController();
//
//   // _allItems holds the full data from API
//   List<FilterItem> _allItems = [];
//   // _displayedItems is what shows in ListView (filtered by search)
//   List<FilterItem> _displayedItems = [];
//
//   bool _isLoading = true;
//   String _errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }
//
//   Future<void> _fetchData() async {
//     try {
//       final items = await _apiService.fetchGenericFilter(
//         categoryId: widget.categoryId,
//         filterType: widget.filterType,
//       );
//
//       setState(() {
//         _allItems = items;
//         _syncSelections();
//         _displayedItems = List.from(_allItems); // Initially show all
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _syncSelections() {
//     // Mark items as selected based on passed props
//     final selectedIds = widget.preSelectedItems.map((e) => e.id).toSet();
//     for (var item in _allItems) {
//       if (selectedIds.contains(item.id)) {
//         item.isSelected = true;
//       }
//       for (var child in item.children) {
//         if (selectedIds.contains(child.id)) {
//           child.isSelected = true;
//           item.isExpanded = true;
//         }
//       }
//     }
//   }
//
//   void _filterList(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _displayedItems = List.from(_allItems);
//       } else {
//         _displayedItems = _allItems.where((item) {
//           return item.name.toLowerCase().contains(query.toLowerCase());
//         }).toList();
//       }
//     });
//   }
//
//   void _clearSelection() {
//     setState(() {
//       for (var item in _allItems) {
//         item.isSelected = false;
//         for (var child in item.children) {
//           child.isSelected = false;
//         }
//       }
//       _searchController.clear();
//       _filterList('');
//     });
//   }
//
//   void _onDonePressed() {
//     List<FilterItem> selectedItems = [];
//     for (var item in _allItems) {
//       if (item.isSelected) selectedItems.add(item);
//       for (var child in item.children) {
//         if (child.isSelected) selectedItems.add(child);
//       }
//     }
//     Navigator.pop(context, selectedItems);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: _onDonePressed, // Auto-save on back
//         ),
//         title: Text(
//           widget.appBarTitle.toUpperCase(),
//           style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           TextButton(
//             onPressed: _clearSelection,
//             child: const Text("Clear All", style: TextStyle(color: Colors.grey)),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // --- SEARCH BAR (Visible for all, or condition it like if (items > 10)) ---
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: const BoxDecoration(
//               border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
//             ),
//             child: TextField(
//               controller: _searchController,
//               onChanged: _filterList,
//               decoration: InputDecoration(
//                 hintText: "Search ${widget.appBarTitle}...",
//                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//
//           // --- LIST CONTENT ---
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _errorMessage.isNotEmpty
//                 ? Center(child: Text(_errorMessage))
//                 : _displayedItems.isEmpty
//                 ? const Center(child: Text("No items found"))
//                 : ListView.separated(
//               itemCount: _displayedItems.length,
//               separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 16),
//               itemBuilder: (context, index) {
//                 final item = _displayedItems[index];
//                 return _buildCheckboxTile(item);
//               },
//             ),
//           ),
//
//           // --- BOTTOM DONE BUTTON ---
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
//                 ),
//                 onPressed: _onDonePressed,
//                 child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCheckboxTile(FilterItem item) {
//     if (item.children.isNotEmpty) {
//       // Expandable tile for categories with children
//       return ExpansionTile(
//         title: Text(item.name, style: const TextStyle(fontSize: 15)),
//         leading: Checkbox(
//           activeColor: Colors.black,
//           value: item.isSelected,
//           onChanged: (bool? value) {
//             setState(() {
//               item.isSelected = value!;
//               // Optional: Select/Deselect all children based on parent
//               for (var child in item.children) child.isSelected = false;
//             });
//           },
//         ),
//         children: item.children.map((child) {
//           return ListTile(
//             contentPadding: const EdgeInsets.only(left: 40, right: 20),
//             title: Text(child.name, style: const TextStyle(fontSize: 14)),
//             leading: Checkbox(
//               activeColor: Colors.black,
//               value: child.isSelected,
//               onChanged: (bool? value) {
//                 setState(() {
//                   child.isSelected = value!;
//                   if (value) item.isSelected = false; // Deselect parent if child selected
//                 });
//               },
//             ),
//           );
//         }).toList(),
//       );
//     } else {
//       // Standard tile
//       return ListTile(
//         onTap: () {
//           setState(() {
//             item.isSelected = !item.isSelected;
//           });
//         },
//         title: Text(item.name, style: const TextStyle(fontSize: 15)),
//         trailing: item.isSelected
//             ? const Icon(Icons.check, color: Colors.black) // Tick mark on right
//             : null, // Or use Checkbox on left if preferred
//       );
//     }
//   }
// }

//5/12/2025
// class GenericFilterScreen extends StatefulWidget {
//   final String categoryId;
//   final String filterType;
//   final String appBarTitle;
//   final String? parentCategoryId;
// // ✅ Receive previously selected items
//   final List<FilterItem> preSelectedItems;
//   const GenericFilterScreen({
//     Key? key,
//     required this.categoryId,
//     required this.filterType,
//     required this.appBarTitle,
//     this.parentCategoryId,
//     this.preSelectedItems = const [], // Default empty
//   }) : super(key: key);
//   @override
//   State<GenericFilterScreen> createState() => _GenericFilterScreenState();
// }
// class _GenericFilterScreenState extends State<GenericFilterScreen> {
//   late Future<List<FilterItem>> _filterFuture;
//   final ApiService _apiService = ApiService();
//   List<FilterItem> _dynamicFilterList = [];
//   @override
//   void initState() {
//     super.initState();
//     _filterFuture = _apiService.fetchGenericFilter(
//       categoryId: widget.categoryId,
//       filterType: widget.filterType,
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(widget.appBarTitle),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
// // Add a checkmark/done button in AppBar optionally
//         actions: [
//           TextButton(
//             onPressed: _onDonePressed,
//             child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: FutureBuilder<List<FilterItem>>(
//               future: _filterFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text('No ${widget.filterType} found.'));
//                 }
//
// // Initial Load: Sync with preSelectedItems
//                 if (_dynamicFilterList.isEmpty) {
//                   _dynamicFilterList = snapshot.data!;
//                   _syncSelections();
//                 }
//
//                 return ListView.builder(
//                   itemCount: _dynamicFilterList.length,
//                   itemBuilder: (context, index) {
//                     final item = _dynamicFilterList[index];
//                     return _buildFilterTile(item);
//                   },
//                 );
//               },
//             ),
//           ),
//           _buildDoneButton(),
//         ],
//       ),
//     );
//   }
// // ✅ Helper to mark items as true if they were passed in
//   void _syncSelections() {
// // Extract IDs of pre-selected items for easy lookup
//     final selectedIds = widget.preSelectedItems.map((e) => e.id).toSet();
//
//     for (var item in _dynamicFilterList) {
//       if (selectedIds.contains(item.id)) {
//         item.isSelected = true;
//       }
//       // Also check children
//       for (var child in item.children) {
//         if (selectedIds.contains(child.id)) {
//           child.isSelected = true;
//           // Ideally if child is selected, expand the parent
//           item.isExpanded = true;
//         }
//       }
//     }
//   }
//   Widget _buildFilterTile(FilterItem item) {
// // ... (Your existing UI code for ExpansionTile/ListTile remains exactly the same)
// // Just ensure you are modifying item.isSelected in the setState
//
//     final containerDecoration = BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 6,
//           offset: const Offset(0, 3),
//         ),
//       ],
//     );
//
//     if (item.children.isNotEmpty) {
//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: containerDecoration,
//         child: Theme(
//           data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//           child: ExpansionTile(
//             key: PageStorageKey(item.name),
//             initiallyExpanded: item.isExpanded,
//             onExpansionChanged: (expanded) => setState(() => item.isExpanded = expanded),
//             title: Row(
//               children: [
//                 Checkbox(
//                   value: item.isSelected,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       item.isSelected = value!;
//                       if (value) {
//                         // clear children if parent selected (logic depends on your requirement)
//                         for (var child in item.children) child.isSelected = false;
//                       }
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
//                 ),
//               ],
//             ),
//             children: item.children.map((child) {
//               return Padding(
//                 padding: const EdgeInsets.only(left: 20),
//                 child: Row(
//                   children: [
//                     Checkbox(
//                       value: child.isSelected,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           child.isSelected = value!;
//                           if (value) item.isSelected = false;
//                         });
//                       },
//                     ),
//                     Expanded(child: Text(child.name)),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: containerDecoration,
//         child: ListTile(
//           leading: Checkbox(
//             value: item.isSelected,
//             onChanged: (val) => setState(() => item.isSelected = val!),
//           ),
//           title: Text(item.name),
//           onTap: () => setState(() => item.isSelected = !item.isSelected),
//         ),
//       );
//     }
//   }
//   Widget _buildDoneButton() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//           onPressed: _onDonePressed,
//           child: const Text("Done", style: TextStyle(color: Colors.white)),
//         ),
//       ),
//     );
//   }
//   void _onDonePressed() {
//     List<FilterItem> selectedItems = [];
//
//     for (var item in _dynamicFilterList) {
//       if (item.isSelected) {
//         selectedItems.add(item);
//       }
//       for (var child in item.children) {
//         if (child.isSelected) {
//           selectedItems.add(child);
//         }
//       }
//     }
//
// // ✅ Return the list to the Previous Screen (BottomSheet)
//     Navigator.pop(context, selectedItems);
//   }
// }

// class GenericFilterScreen extends StatefulWidget {
//   final String categoryId;
//   final String filterType;
//   final String appBarTitle;
//   final List<FilterItem> preSelectedItems; // Received from Bottom Sheet
//
//   const GenericFilterScreen({
//     Key? key,
//     required this.categoryId,
//     required this.filterType,
//     required this.appBarTitle,
//     this.preSelectedItems = const [],
//   }) : super(key: key);
//
//   @override
//   State<GenericFilterScreen> createState() => _GenericFilterScreenState();
// }
//
// class _GenericFilterScreenState extends State<GenericFilterScreen> {
//   late Future<List<FilterItem>> _filterFuture;
//   final ApiService _apiService = ApiService();
//   List<FilterItem> _dynamicFilterList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _filterFuture = _apiService.fetchGenericFilter(
//       categoryId: widget.categoryId,
//       filterType: widget.filterType,
//     );
//   }
//
//   // ✅ SYNC LOGIC: Matches API items with Pre-Selected items
//   void _syncSelections() {
//     // Create a Set of IDs for O(1) lookup performance
//     final selectedIds = widget.preSelectedItems.map((e) => e.id.toString().trim()).toSet();
//
//     for (var item in _dynamicFilterList) {
//       // Check Parent
//       if (selectedIds.contains(item.id.toString().trim())) {
//         item.isSelected = true;
//       }
//       // Check Children (if any)
//       for (var child in item.children) {
//         if (selectedIds.contains(child.id.toString().trim())) {
//           child.isSelected = true;
//           item.isExpanded = true; // Auto-expand if child is selected
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(widget.appBarTitle),
//         actions: [
//           TextButton(
//             onPressed: _onDonePressed,
//             child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
//           )
//         ],
//       ),
//       body: FutureBuilder<List<FilterItem>>(
//         future: _filterFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No options found"));
//           }
//
//           // ✅ ONLY SYNC ONCE when data is first loaded
//           if (_dynamicFilterList.isEmpty) {
//             _dynamicFilterList = snapshot.data!;
//             _syncSelections();
//           }
//
//           return ListView.builder(
//             itemCount: _dynamicFilterList.length,
//             itemBuilder: (context, index) {
//               return _buildFilterTile(_dynamicFilterList[index]);
//             },
//           );
//         },
//       ),
//     );
//   }
// // class GenericFilterScreen extends StatefulWidget {
// //   final String categoryId;
// //   final String filterType;
// //   final String appBarTitle;
// //   final String? parentCategoryId;
// //   // ✅ Receive previously selected items
// //   final List<FilterItem> preSelectedItems;
// //
// //   const GenericFilterScreen({
// //     Key? key,
// //     required this.categoryId,
// //     required this.filterType,
// //     required this.appBarTitle,
// //     this.parentCategoryId,
// //     this.preSelectedItems = const [], // Default empty
// //   }) : super(key: key);
// //
// //   @override
// //   State<GenericFilterScreen> createState() => _GenericFilterScreenState();
// // }
// //
// // class _GenericFilterScreenState extends State<GenericFilterScreen> {
// //   late Future<List<FilterItem>> _filterFuture;
// //   final ApiService _apiService = ApiService();
// //   List<FilterItem> _dynamicFilterList = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _filterFuture = _apiService.fetchGenericFilter(
// //       categoryId: widget.categoryId,
// //       filterType: widget.filterType,
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         title: Text(widget.appBarTitle),
// //         backgroundColor: Colors.white,
// //         foregroundColor: Colors.black,
// //         elevation: 1,
// //         // Add a checkmark/done button in AppBar optionally
// //         actions: [
// //           TextButton(
// //             onPressed: _onDonePressed,
// //             child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
// //           )
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: FutureBuilder<List<FilterItem>>(
// //               future: _filterFuture,
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 }
// //                 if (snapshot.hasError) {
// //                   return Center(child: Text('Error: ${snapshot.error}'));
// //                 }
// //                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //                   return Center(child: Text('No ${widget.filterType} found.'));
// //                 }
// //
// //                 // Initial Load: Sync with preSelectedItems
// //                 if (_dynamicFilterList.isEmpty) {
// //                   _dynamicFilterList = snapshot.data!;
// //                   _syncSelections();
// //                 }
// //
// //                 return ListView.builder(
// //                   itemCount: _dynamicFilterList.length,
// //                   itemBuilder: (context, index) {
// //                     final item = _dynamicFilterList[index];
// //                     return _buildFilterTile(item);
// //                   },
// //                 );
// //               },
// //             ),
// //           ),
// //           _buildDoneButton(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ✅ Helper to mark items as true if they were passed in
// //   void _syncSelections() {
// //     // Extract IDs of pre-selected items for easy lookup
// //     final selectedIds = widget.preSelectedItems.map((e) => e.id).toSet();
// //
// //     for (var item in _dynamicFilterList) {
// //       if (selectedIds.contains(item.id)) {
// //         item.isSelected = true;
// //       }
// //       // Also check children
// //       for (var child in item.children) {
// //         if (selectedIds.contains(child.id)) {
// //           child.isSelected = true;
// //           // Ideally if child is selected, expand the parent
// //           item.isExpanded = true;
// //         }
// //       }
// //     }
// //   }
//
//   Widget _buildFilterTile(FilterItem item) {
//     // ... (Your existing UI code for ExpansionTile/ListTile remains exactly the same)
//     // Just ensure you are modifying `item.isSelected` in the setState
//
//     final containerDecoration = BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 6,
//           offset: const Offset(0, 3),
//         ),
//       ],
//     );
//
//     if (item.children.isNotEmpty) {
//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: containerDecoration,
//         child: Theme(
//           data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//           child: ExpansionTile(
//             key: PageStorageKey(item.name),
//             initiallyExpanded: item.isExpanded,
//             onExpansionChanged: (expanded) => setState(() => item.isExpanded = expanded),
//             title: Row(
//               children: [
//                 Checkbox(
//                   value: item.isSelected,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       item.isSelected = value!;
//                       if (value) {
//                         // clear children if parent selected (logic depends on your requirement)
//                         for (var child in item.children) child.isSelected = false;
//                       }
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
//                 ),
//               ],
//             ),
//             children: item.children.map((child) {
//               return Padding(
//                 padding: const EdgeInsets.only(left: 20),
//                 child: Row(
//                   children: [
//                     Checkbox(
//                       value: child.isSelected,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           child.isSelected = value!;
//                           if (value) item.isSelected = false;
//                         });
//                       },
//                     ),
//                     Expanded(child: Text(child.name)),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: containerDecoration,
//         child: ListTile(
//           leading: Checkbox(
//             value: item.isSelected,
//             onChanged: (val) => setState(() => item.isSelected = val!),
//           ),
//           title: Text(item.name),
//           onTap: () => setState(() => item.isSelected = !item.isSelected),
//         ),
//       );
//     }
//   }
//
//   Widget _buildDoneButton() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//           onPressed: _onDonePressed,
//           child: const Text("Done", style: TextStyle(color: Colors.white)),
//         ),
//       ),
//     );
//   }
//
//   void _onDonePressed() {
//     List<FilterItem> selectedItems = [];
//
//     for (var item in _dynamicFilterList) {
//       if (item.isSelected) {
//         selectedItems.add(item);
//       }
//       for (var child in item.children) {
//         if (child.isSelected) {
//           selectedItems.add(child);
//         }
//       }
//     }
//
//     // ✅ Return the list to the Previous Screen (BottomSheet)
//     Navigator.pop(context, selectedItems);
//   }
// }

//8/11/2025
// class GenericFilterScreen extends StatefulWidget {
//   final String categoryId;
//   final String filterType; // e.g., 'categories', 'designers'
//   final String appBarTitle;
//
//   const GenericFilterScreen({
//     Key? key,
//     required this.categoryId,
//     required this.filterType,
//     required this.appBarTitle,
//   }) : super(key: key);
//
//   @override
//   State<GenericFilterScreen> createState() => _GenericFilterScreenState();
// }
//
// class _GenericFilterScreenState extends State<GenericFilterScreen> {
//   late Future<List<FilterItem>> _filterFuture;
//   final ApiService _apiService = ApiService();
//   List<FilterItem> _dynamicFilterList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _filterFuture = _apiService.fetchGenericFilter(
//       categoryId: widget.categoryId,
//       filterType: widget.filterType,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(widget.appBarTitle),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: FutureBuilder<List<FilterItem>>(
//               future: _filterFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text('No ${widget.filterType} found.'));
//                 }
//
//                 if (_dynamicFilterList.isEmpty) {
//                   _dynamicFilterList = snapshot.data!;
//                 }
//
//                 return ListView.builder(
//                   itemCount: _dynamicFilterList.length,
//                   itemBuilder: (context, index) {
//                     final item = _dynamicFilterList[index];
//                     return _buildFilterTile(item);
//                   },
//                 );
//               },
//             ),
//           ),
//           _buildApplyButton(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterTile(FilterItem item) {
//     // Common styling for the card
//     final containerDecoration = BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 6,
//           offset: const Offset(0, 3),
//         ),
//       ],
//     );
//
//     // ✅ CASE 1: Item has children, build an expandable tile.
//     if (item.children.isNotEmpty) {
//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: containerDecoration,
//         child: Theme(
//           // Removes the default divider line from the ExpansionTile
//           data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//           child: ExpansionTile(
//             key: PageStorageKey(item.name), // Helps preserve open/closed state
//             initiallyExpanded: item.isExpanded,
//             onExpansionChanged: (expanded) {
//               setState(() {
//                 item.isExpanded = expanded;
//               });
//             },
//
//             tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             childrenPadding:
//             const EdgeInsets.only(bottom: 12, left: 20, right: 12),
//
//             // Title contains the parent checkbox and name
//             title: Row(
//               children: [
//                 Checkbox(
//                   value: item.isSelected,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4)),
//                   onChanged: (bool? value) {
//                     setState(() {
//                       item.isSelected = value!;
//                       // If parent is selected, deselect all children
//                       if (value) {
//                         for (var child in item.children) {
//                           child.isSelected = false;
//                         }
//                       }
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: Text(
//                     item.name,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.w600, fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//
//             // This is the dropdown arrow icon you want!
//             trailing: Icon(
//               item.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//               color: Colors.black54,
//             ),
//
//             // The list of children with their own checkboxes
//             children: item.children.map((child) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                 child: Row(
//                   children: [
//                     Checkbox(
//                       value: child.isSelected,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4)),
//                       onChanged: (bool? value) {
//                         setState(() {
//                           child.isSelected = value!;
//                           // If a child is selected, deselect the parent
//                           if (value) {
//                             item.isSelected = false;
//                           }
//                         });
//                       },
//                     ),
//                     Expanded(child: Text(child.name)),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       );
//     }
//     // ✅ CASE 2: Item has NO children, build a simple tile.
//     else {
//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: containerDecoration,
//         child: ListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           leading: Checkbox(
//             value: item.isSelected,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//             onChanged: (bool? value) {
//               setState(() {
//                 item.isSelected = value!;
//               });
//             },
//           ),
//           title: Text(
//             item.name,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//           ),
//           onTap: () {
//             setState(() {
//               item.isSelected = !item.isSelected;
//             });
//           },
//         ),
//       );
//     }
//   }
//
//   Widget _buildApplyButton() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//           onPressed: () async { // Made onPressed async
//             List<Map<String, dynamic>> selectedItems = [];
//             String? primaryCategoryName;
//
//             for (var item in _dynamicFilterList) {
//               if (item.isSelected) {
//                 selectedItems.add({
//                   "id": item.id,
//                   "name": item.name,
//                   "type": widget.filterType
//                 });
//                 // If a category is selected (parent), use its name
//                 if (widget.filterType == 'categories') {
//                   primaryCategoryName = item.name;
//                 }
//               }
//               for (var child in item.children) {
//                 if (child.isSelected) {
//                   selectedItems.add({
//                     "id": child.id,
//                     "name": child.name,
//                     "type": widget.filterType
//                   });
//                   // If a category child is selected, use its name
//                   if (widget.filterType == 'categories') {
//                     primaryCategoryName = child.name;
//                   }
//                 }
//               }
//             }
//
//             // Determine the category name to pass.
//             // Prioritize a category selected within the filters.
//             // Otherwise, use the original appBarTitle.
//             // If appBarTitle itself is a filter type (like "Select Size", "Occasion"),
//             // we need a reliable fallback that is an actual category.
//             // For now, sticking to the existing logic which seems to assume appBarTitle is a category.
//             // If widget.appBarTitle can sometimes be 'Select Size' or 'Occasion',
//             // you might need an additional fallback here, e.g., to a default "All Products" category.
//             final String finalCategoryName = primaryCategoryName ?? widget.appBarTitle;
//
//             if (selectedItems.isNotEmpty) {
//               print('Applying Filters: $selectedItems');
//
//               final List<Map<String, String>> correctlyTypedFilters =
//               selectedItems.map((item) {
//                 return {
//                   'type': item['type'].toString(),
//                   'id': item['id'].toString(),
//                   'name': item['name'].toString(),
//                 };
//               }).toList();
//
//               // Check if finalCategoryName is a valid category before navigating
//               // This is a crucial part to prevent navigation with invalid category names
//               // You might need to adjust ApiService to expose a method to validate categoryName
//               // or simply ensure that widget.appBarTitle is always a valid category name
//               // when the filter screen is opened.
//
//               // For now, let's assume widget.appBarTitle is a valid category to start with
//               // and primaryCategoryName will override it if a sub-category is selected.
//
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => FilteredProductsScreen(
//                     categoryId: widget.categoryId,
//                     categoryName: finalCategoryName,
//                     selectedFilters: correctlyTypedFilters,
//                   ),
//                 ),
//               );
//             } else {
//               // If no filters are selected, navigate to the original category with no filters.
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => FilteredProductsScreen(
//                     categoryId: widget.categoryId,
//                     categoryName: widget.appBarTitle, // Use the original app bar title
//                     selectedFilters: [], // No filters applied
//                   ),
//                 ),
//               );
//             }
//           },
//           child: const Text("Apply", style: TextStyle(color: Colors.white)),
//         ),
//       ),
//     );
//   }
//   // Widget _buildApplyButton() {
//   //   return Padding(
//   //     padding: const EdgeInsets.all(16.0),
//   //     child: SizedBox(
//   //       width: double.infinity,
//   //       child: ElevatedButton(
//   //         style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//   //         onPressed: () {
//   //           List<Map<String, dynamic>> selectedItems = [];
//   //           String? primaryCategoryName; // To store the selected category name
//   //
//   //           for (var item in _dynamicFilterList) {
//   //             if (item.isSelected) {
//   //               selectedItems.add({
//   //                 "id": item.id,
//   //                 "name": item.name,
//   //                 "type": widget.filterType
//   //               });
//   //               // ✅ CORRECTED LOGIC: If a category is selected (parent), use its name
//   //               if (widget.filterType == 'categories') {
//   //                 primaryCategoryName = item.name;
//   //               }
//   //             }
//   //             for (var child in item.children) {
//   //               if (child.isSelected) {
//   //                 selectedItems.add({
//   //                   "id": child.id,
//   //                   "name": child.name,
//   //                   "type": widget.filterType
//   //                 });
//   //                 // If a category child is selected, use its name
//   //                 if (widget.filterType == 'categories') {
//   //                   primaryCategoryName = child.name;
//   //                 }
//   //               }
//   //             }
//   //           }
//   //
//   //           // Fallback if no specific category was selected in the filter itself,
//   //           // or if the filterType wasn't 'categories'.
//   //           // In this case, use the original category name from appBarTitle.
//   //           // This is especially important if filterType is 'colors' or 'designers'
//   //           // and you still want the filter button to work based on the *original* category.
//   //           final String finalCategoryName = primaryCategoryName ?? widget.appBarTitle;
//   //
//   //           if (selectedItems.isNotEmpty) {
//   //             print('Applying Filters: $selectedItems');
//   //
//   //             final List<Map<String, String>> correctlyTypedFilters =
//   //             selectedItems.map((item) {
//   //               return {
//   //                 'type': item['type'].toString(),
//   //                 'id': item['id'].toString(),
//   //                 'name': item['name'].toString(),
//   //               };
//   //             }).toList();
//   //
//   //             Navigator.of(context).push(
//   //               MaterialPageRoute(
//   //                 builder: (context) => FilteredProductsScreen(
//   //                   categoryId: widget.categoryId,
//   //                   categoryName: finalCategoryName, // Pass the correct category name
//   //                   selectedFilters: correctlyTypedFilters,
//   //                 ),
//   //               ),
//   //             );
//   //           } else {
//   //             // If no filters are selected, simply navigate back with the original category name
//   //             // or pop, depending on desired behavior.
//   //             // For now, let's assume if no specific filter is applied, you still
//   //             // want to show products for the initial category.
//   //             Navigator.of(context).push(
//   //               MaterialPageRoute(
//   //                 builder: (context) => FilteredProductsScreen(
//   //                   categoryId: widget.categoryId,
//   //                   categoryName: widget.appBarTitle, // Use the original app bar title
//   //                   selectedFilters: [], // No filters applied
//   //                 ),
//   //               ),
//   //             );
//   //           }
//   //         },
//   //         child: const Text("Apply", style: TextStyle(color: Colors.white)),
//   //       ),
//   //     ),
//   //   );
//   // }
//   //8/11/2025
//   // Widget _buildApplyButton() {
//   //   return Padding(
//   //       padding: const EdgeInsets.all(16.0),
//   //   child: SizedBox(
//   //   width: double.infinity,
//   //   child: ElevatedButton(
//   //   style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//   //   onPressed: () {
//   //   List<Map<String, dynamic>> selectedItems = [];
//   //   for (var item in _dynamicFilterList) {
//   //   if (item.isSelected) {
//   //   selectedItems.add({
//   //   "id": item.id,
//   //   "name": item.name,
//   //   "type": widget.filterType
//   //   });
//   //   }
//   //   for (var child in item.children) {
//   //   if (child.isSelected) {
//   //   selectedItems.add({
//   //   "id": child.id,
//   //   "name": child.name,
//   //   "type": widget.filterType
//   //   });
//   //   }
//   //   }
//   //   }
//   //
//   //   // The corrected code in generic_filter_screen.dart
//   //   if (selectedItems.isNotEmpty) {
//   //   print('Applying Filters: $selectedItems');
//   //
//   //   // ✅ 1. CONVERT THE LIST TO THE CORRECT TYPE
//   //   // We iterate through the list of dynamic maps and create a new list
//   //   // of strictly typed maps.
//   //   final List<Map<String, String>> correctlyTypedFilters =
//   //   selectedItems.map((item) {
//   //   // For each item, create a new Map<String, String>.
//   //   // Using .toString() is a safe way to handle values that might
//   //   // be numbers (like an ID) or already strings.
//   //   return {
//   //   'type': item['type'].toString(),
//   //   'id': item['id'].toString(),
//   //   'name': item['name'].toString(),
//   //   };
//   //   }).toList();
//   //
//   //   // ✅ 2. NAVIGATE WITH THE CORRECTLY TYPED DATA AND ADD categoryName
//   //   Navigator.of(context).push(
//   //   MaterialPageRoute(
//   //   builder: (context) => FilteredProductsScreen(
//   //   categoryId: widget.categoryId,
//   //   categoryName: widget.appBarTitle, // Pass the appBarTitle here
//   //   // Pass the new, correctly typed list.
//   //   selectedFilters: correctlyTypedFilters,
//   //   ),
//   //   ),
//   //   );
//   //   } else {
//   //   Navigator.pop(
//   //   context); // Just close the filter screen if nothing was selected
//   //   }
//   //   },
//   //   child: const Text("Apply", style: TextStyle(color: Colors.white)),
//   //   ),
//   //   ));
//   // }
// }

//7/11/2025
//   class GenericFilterScreen extends StatefulWidget {
//     final String categoryId;
//     final String filterType; // e.g., 'categories', 'designers'
//     final String appBarTitle;
//
//     const GenericFilterScreen({
//       Key? key,
//       required this.categoryId,
//       required this.filterType,
//       required this.appBarTitle,
//     }) : super(key: key);
//
//     @override
//     State<GenericFilterScreen> createState() => _GenericFilterScreenState();
//   }
//
//   class _GenericFilterScreenState extends State<GenericFilterScreen> {
//     late Future<List<FilterItem>> _filterFuture;
//     final ApiService _apiService = ApiService();
//     List<FilterItem> _dynamicFilterList = [];
//
//     @override
//     void initState() {
//       super.initState();
//       _filterFuture = _apiService.fetchGenericFilter(
//         categoryId: widget.categoryId,
//         filterType: widget.filterType,
//       );
//     }
//
//     @override
//     Widget build(BuildContext context) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: Text(widget.appBarTitle),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 1,
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: FutureBuilder<List<FilterItem>>(
//                 future: _filterFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return Center(child: Text('No ${widget.filterType} found.'));
//                   }
//
//                   if (_dynamicFilterList.isEmpty) {
//                     _dynamicFilterList = snapshot.data!;
//                   }
//
//                   return ListView.builder(
//                     itemCount: _dynamicFilterList.length,
//                     itemBuilder: (context, index) {
//                       final item = _dynamicFilterList[index];
//                       return _buildFilterTile(item);
//                     },
//                   );
//
//
//
//                 },
//               ),
//             ),
//             _buildApplyButton(),
//           ],
//         ),
//       );
//     }
//
//     Widget _buildFilterTile(FilterItem item) {
//       // Common styling for the card
//       final containerDecoration = BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       );
//
//       // ✅ CASE 1: Item has children, build an expandable tile.
//       if (item.children.isNotEmpty) {
//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: containerDecoration,
//           child: Theme(
//             // Removes the default divider line from the ExpansionTile
//             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//             child: ExpansionTile(
//               key: PageStorageKey(item.name), // Helps preserve open/closed state
//               initiallyExpanded: item.isExpanded,
//               onExpansionChanged: (expanded) {
//                 setState(() {
//                   item.isExpanded = expanded;
//                 });
//               },
//
//               tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               childrenPadding: const EdgeInsets.only(bottom: 12, left: 20, right: 12),
//
//               // Title contains the parent checkbox and name
//               title: Row(
//                 children: [
//                   Checkbox(
//                     value: item.isSelected,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//                     onChanged: (bool? value) {
//                       setState(() {
//                         item.isSelected = value!;
//                         // If parent is selected, deselect all children
//                         if (value) {
//                           for (var child in item.children) {
//                             child.isSelected = false;
//                           }
//                         }
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       item.name,
//                       style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // This is the dropdown arrow icon you want!
//               trailing: Icon(
//                 item.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//                 color: Colors.black54,
//               ),
//
//               // The list of children with their own checkboxes
//               children: item.children.map((child) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                   child: Row(
//                     children: [
//                       Checkbox(
//                         value: child.isSelected,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//                         onChanged: (bool? value) {
//                           setState(() {
//                             child.isSelected = value!;
//                             // If a child is selected, deselect the parent
//                             if (value) {
//                               item.isSelected = false;
//                             }
//                           });
//                         },
//                       ),
//                       Expanded(child: Text(child.name)),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         );
//       }
//       // ✅ CASE 2: Item has NO children, build a simple tile.
//       else {
//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: containerDecoration,
//           child: ListTile(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             leading: Checkbox(
//               value: item.isSelected,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//               onChanged: (bool? value) {
//                 setState(() {
//                   item.isSelected = value!;
//                 });
//               },
//             ),
//             title: Text(
//               item.name,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//             ),
//             onTap: () {
//               setState(() {
//                 item.isSelected = !item.isSelected;
//               });
//             },
//           ),
//         );
//       }
//     }
//
//
//
//
// // 3/11/2025
//     // Widget _buildFilterTile(FilterItem item) {
//     //   final containerDecoration = BoxDecoration(
//     //     color: Colors.white,
//     //     borderRadius: BorderRadius.circular(14),
//     //     boxShadow: [
//     //       BoxShadow(
//     //         color: Colors.black.withOpacity(0.05),
//     //         blurRadius: 6,
//     //         offset: const Offset(0, 3),
//     //       ),
//     //     ],
//     //   );
//     //
//     //   // CASE 1: Expandable parent with children
//     //   if (item.children.isNotEmpty) {
//     //     return Container(
//     //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     //       decoration: containerDecoration,
//     //       child: Theme(
//     //         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//     //         child: ExpansionTile(
//     //           tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//     //           childrenPadding: const EdgeInsets.only(bottom: 12, left: 20, right: 12),
//     //           leading: Checkbox(
//     //             value: item.isSelected,
//     //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//     //             onChanged: (bool? value) {
//     //               setState(() {
//     //                 item.isSelected = value!;
//     //                 if (value) {
//     //                   for (var child in item.children) {
//     //                     child.isSelected = false;
//     //                   }
//     //                 }
//     //               });
//     //             },
//     //           ),
//     //           title: Text(
//     //             item.name,
//     //             style: const TextStyle(
//     //               fontWeight: FontWeight.w600,
//     //               fontSize: 16,
//     //               color: Colors.black87,
//     //             ),
//     //           ),
//     //           initiallyExpanded: item.isExpanded,
//     //           onExpansionChanged: (bool expanded) {
//     //             setState(() {
//     //               item.isExpanded = expanded;
//     //             });
//     //           },
//     //           children: item.children.map<Widget>((child) {
//     //             return Padding(
//     //               padding: const EdgeInsets.symmetric(vertical: 4),
//     //               child: Row(
//     //                 children: [
//     //                   Checkbox(
//     //                     value: child.isSelected,
//     //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//     //                     onChanged: (bool? value) {
//     //                       setState(() {
//     //                         child.isSelected = value!;
//     //                         if (value) {
//     //                           item.isSelected = false;
//     //                         }
//     //                       });
//     //                     },
//     //                   ),
//     //                   Expanded(
//     //                     child: Text(
//     //                       child.name,
//     //                       style: const TextStyle(
//     //                         fontSize: 14,
//     //                         fontWeight: FontWeight.w400,
//     //                         color: Colors.black87,
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
//     //             );
//     //           }).toList(),
//     //         ),
//     //       ),
//     //     );
//     //   }
//     //
//     //   // CASE 2: Simple tile with no children
//     //   else {
//     //     return Container(
//     //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     //       decoration: containerDecoration,
//     //       child: ListTile(
//     //         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//     //         leading: Checkbox(
//     //           value: item.isSelected,
//     //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//     //           onChanged: (bool? value) {
//     //             setState(() {
//     //               item.isSelected = value!;
//     //             });
//     //           },
//     //         ),
//     //         title: Text(
//     //           item.name,
//     //           style: const TextStyle(
//     //             fontWeight: FontWeight.w600,
//     //             fontSize: 16,
//     //             color: Colors.black87,
//     //           ),
//     //         ),
//     //         onTap: () {
//     //           setState(() {
//     //             item.isSelected = !item.isSelected;
//     //           });
//     //         },
//     //       ),
//     //     );
//     //   }
//     // }
//
//     // Widget _buildFilterTile(FilterItem item) {
//     //   // A common container style for both tile types
//     //   final containerDecoration = BoxDecoration(
//     //     color: const Color(0xFFD3D4D3),
//     //     borderRadius: BorderRadius.circular(12),
//     //     boxShadow: [
//     //       BoxShadow(
//     //         color: Colors.grey.withOpacity(0.15),
//     //         blurRadius: 4,
//     //         offset: const Offset(0, 3),
//     //       ),
//     //     ],
//     //   );
//     //
//     //   // CASE 1: The item has children, so we build an expandable tile.
//     //   if (item.children.isNotEmpty) {
//     //     return Container(
//     //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     //       decoration: containerDecoration,
//     //       child: Theme(
//     //         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//     //         child: ExpansionTile(
//     //           tilePadding: const EdgeInsets.symmetric(horizontal: 16),
//     //           childrenPadding: const EdgeInsets.only(bottom: 12, left: 20),
//     //           title: Row(
//     //             children: [
//     //               Checkbox(
//     //                 value: item.isSelected,
//     //                 onChanged: (bool? value) {
//     //                   setState(() {
//     //                     item.isSelected = value!;
//     //                     // If the parent is selected, deselect all its children
//     //                     if (value) {
//     //                       for (var child in item.children) {
//     //                         child.isSelected = false;
//     //                       }
//     //                     }
//     //                   });
//     //                 },
//     //               ),
//     //               Expanded(
//     //                 child: Text(
//     //                   item.name,
//     //                   style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//     //                 ),
//     //               ),
//     //             ],
//     //           ),
//     //           initiallyExpanded: item.isExpanded,
//     //           onExpansionChanged: (bool expanded) {
//     //             setState(() {
//     //               item.isExpanded = expanded;
//     //             });
//     //           },
//     //           children: item.children.map<Widget>((child) {
//     //             return Row(
//     //               children: [
//     //                 Checkbox(
//     //                   value: child.isSelected,
//     //                   onChanged: (bool? value) {
//     //                     setState(() {
//     //                       child.isSelected = value!;
//     //                       // If a child is selected, deselect the parent
//     //                       if (value) {
//     //                         item.isSelected = false;
//     //                       }
//     //                     });
//     //                   },
//     //                 ),
//     //                 Expanded(child: Text(child.name)),
//     //               ],
//     //             );
//     //           }).toList(),
//     //         ),
//     //       ),
//     //     );
//     //   }
//     //   // CASE 2: The item has NO children, so we build a simple, non-expandable tile.
//     //   else {
//     //     return Container(
//     //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     //       decoration: containerDecoration,
//     //       child: ListTile(
//     //         contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//     //         title: Row(
//     //           children: [
//     //             Checkbox(
//     //               value: item.isSelected,
//     //               onChanged: (bool? value) {
//     //                 setState(() {
//     //                   item.isSelected = value!;
//     //                 });
//     //               },
//     //             ),
//     //             Expanded(
//     //                 child: Text(
//     //                   item.name,
//     //                   style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//     //                 )
//     //             ),
//     //           ],
//     //         ),
//     //         onTap: () {
//     //           // Allow tapping the whole row to toggle the checkbox
//     //           setState(() {
//     //             item.isSelected = !item.isSelected;
//     //           });
//     //         },
//     //       ),
//     //     );
//     //   }
//     // }
//
//     Widget _buildApplyButton() {
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//             onPressed: () {
//               List<Map<String, dynamic>> selectedItems = [];
//               for (var item in _dynamicFilterList) {
//                 if (item.isSelected) {
//                   selectedItems.add({"id": item.id, "name": item.name, "type": widget.filterType});
//                 }
//                 for (var child in item.children) {
//                   if (child.isSelected) {
//                     selectedItems.add({"id": child.id, "name": child.name, "type": widget.filterType});
//                   }
//                 }
//               }
//
//               // The corrected code in generic_filter_screen.dart
//               if (selectedItems.isNotEmpty) {
//                 print('Applying Filters: $selectedItems');
//
//                 // ✅ 1. CONVERT THE LIST TO THE CORRECT TYPE
//                 // We iterate through the list of dynamic maps and create a new list
//                 // of strictly typed maps.
//                 final List<Map<String, String>> correctlyTypedFilters =
//                 selectedItems.map((item) {
//                   // For each item, create a new Map<String, String>.
//                   // Using .toString() is a safe way to handle values that might
//                   // be numbers (like an ID) or already strings.
//                   return {
//                     'type': item['type'].toString(),
//                     'id': item['id'].toString(),
//                     'name': item['name'].toString(),
//                   };
//                 }).toList();
//
//
//                 // ✅ 2. NAVIGATE WITH THE CORRECTLY TYPED DATA
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => FilteredProductsScreen(
//                       categoryId: widget.categoryId,
//
//                       // Pass the new, correctly typed list.
//                       selectedFilters: correctlyTypedFilters,
//                     ),
//                   ),
//                 );
//               } else {
//                 Navigator.pop(context); // Just close the filter screen if nothing was selected
//               }
//             },
//             child: const Text("Apply", style: TextStyle(color: Colors.white)),
//           ),
//         ),
//       );
//     }
//   }