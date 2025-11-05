// import 'dart:convert';
// import 'package:aashniandco/features/designer_details.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class DesignersScreen extends StatefulWidget {
//   @override
//   _DesignersScreenState createState() => _DesignersScreenState();
// }
//
// class _DesignersScreenState extends State<DesignersScreen> {
//   List<String> designers = [];
//   Map<String, List<String>> groupedDesigners = {};
//   bool isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   bool _isSearchVisible = true;
//   double _lastScrollOffset = 0;
//   List<String> filteredDesigners = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDesigners();
//
//     _scrollController.addListener(() {
//       double currentOffset = _scrollController.offset;
//       if (currentOffset > _lastScrollOffset && _isSearchVisible) {
//         setState(() => _isSearchVisible = false);
//       } else if (currentOffset < _lastScrollOffset && !_isSearchVisible) {
//         setState(() => _isSearchVisible = true);
//       }
//       _lastScrollOffset = currentOffset;
//     });
//   }
//
//   Future<void> fetchDesigners() async {
//     final url = Uri.parse(
//         "http://130.61.35.64:8983/solr/aashni_dev/select?q=*:*&fq=categories-store-1_url_path:%22designers%22&facet=true&facet.field=designer_name&facet.limit=-1");
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         final List<dynamic> facetFields =
//         jsonResponse['facet_counts']['facet_fields']['designer_name'];
//
//         List<String> fetchedDesigners =
//         List<String>.from(facetFields.where((e) => e is String));
//
//         setState(() {
//           designers = fetchedDesigners;
//           filteredDesigners = List.from(designers);
//           groupDesigners(filteredDesigners);
//           isLoading = false;
//         });
//       } else {
//         throw Exception("Failed to load designers");
//       }
//     } catch (e) {
//       print("Error fetching designers: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   /// **Groups designers by first letter**
//   void groupDesigners(List<String> designerList) {
//     Map<String, List<String>> grouped = {};
//     for (String designer in designerList) {
//       String firstLetter = designer[0].toUpperCase();
//
//       // Check if the first character is a number
//       if (RegExp(r'^[0-9]').hasMatch(firstLetter)) {
//         firstLetter = '#'; // Group all numbers under '#'
//       }
//
//       if (!grouped.containsKey(firstLetter)) {
//         grouped[firstLetter] = [];
//       }
//       grouped[firstLetter]!.add(designer);
//     }
//
//     // Sort groups alphabetically, ensuring '#' (numbers) come first
//     setState(() {
//       groupedDesigners = Map.fromEntries(grouped.entries.toList()
//         ..sort((a, b) => a.key == '#' ? -1 : b.key == '#' ? 1 : a.key.compareTo(b.key)));
//     });
//   }
//
//
//   /// **Filters designers on search**
//   void _filterDesigners(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredDesigners = List.from(designers);
//       } else {
//         filteredDesigners = designers
//             .where((designer) =>
//             designer.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//       groupDesigners(filteredDesigners); // ✅ Re-group after filtering
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           if (isLoading)
//             const Center(child: CircularProgressIndicator())
//           else
//             ListView.builder(
//               controller: _scrollController,
//               padding: EdgeInsets.only(top: _isSearchVisible ? 80 : 0),
//               itemCount: groupedDesigners.length,
//               itemBuilder: (context, index) {
//                 String firstLetter = groupedDesigners.keys.elementAt(index);
//                 List<String> designerList = groupedDesigners[firstLetter]!;
//
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Section Header
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 8, horizontal: 16),
//                       color: Colors.grey[300],
//                       width: double.infinity,
//                       child: Text(
//                         firstLetter,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     // List of Designers in this section
//                     ...designerList.map((designer) {
//                       return ListTile(
//                         title: Text(designer),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => DesignerDetailScreen(
//                                   designerName: designer),
//                             ),
//                           );
//                         },
//                       );
//                     }).toList(),
//                   ],
//                 );
//               },
//             ),
//
//           if (_isSearchVisible)
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: SizedBox(
//                         height: 50, // ✅ Set height for search bar
//                         child: TextField(
//                           controller: _searchController,
//                           onChanged: _filterDesigners,
//                           decoration: InputDecoration(
//                             hintText: "Search designers...",
//                             prefixIcon: const Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                             contentPadding:
//                             const EdgeInsets.symmetric(vertical: 10),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () {
//                         _searchController.clear();
//                         _filterDesigners('');
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
