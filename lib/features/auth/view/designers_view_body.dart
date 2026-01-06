  /// This widget contains ONLY the UI for the list of designers.
/// It does NOT have a Scaffold, AppBar, or BottomNavigationBar.
import'package:flutter/material.dart';

import '../../../widgets/no_internet_widget.dart';
import '../../designer/bloc/designers_bloc.dart';
import '../../designer/model/designer_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../designer_details.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
bool isNetworkError(String message) {
  return message.contains("SocketException") ||
      message.contains("ClientException") ||
      message.contains("Failed host lookup") ||
      message.contains("Connection refused");
}

class DesignersViewBody extends StatefulWidget {
  const DesignersViewBody({super.key});

  @override
  State<DesignersViewBody> createState() => _DesignersViewBodyState();
}

class _DesignersViewBodyState extends State<DesignersViewBody> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Map<String, List<Designer>> groupedDesigners = {};
  List<Designer> allDesigners = [];

  @override
  void initState() {
    super.initState();
    context.read<DesignersBloc>().add(FetchDesigners());

    _searchController.addListener(() {
      _filterDesigners(_searchController.text);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Group designers alphabetically
  void _groupDesigners(List<Designer> designers) {
    Map<String, List<Designer>> grouped = {};
    for (var designer in designers) {
      String firstLetter = designer.name[0].toUpperCase();
      if (RegExp(r'^[0-9]').hasMatch(firstLetter)) firstLetter = '#';
      grouped.putIfAbsent(firstLetter, () => []).add(designer);
    }

    setState(() {
      groupedDesigners = Map.fromEntries(
        grouped.entries.toList()
          ..sort((a, b) =>
          a.key == '#' ? -1 : (b.key == '#' ? 1 : a.key.compareTo(b.key))),
      );
    });
  }

  /// Filter designers by name
  void _filterDesigners(String query) {
    if (query.isEmpty) {
      _groupDesigners(allDesigners);
      return;
    }

    final filtered = allDesigners
        .where((designer) =>
        designer.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    _groupDesigners(filtered);
  }

  /// Shimmer for loading
  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20, width: double.infinity, color: Colors.white),
                const SizedBox(height: 10),
                Container(height: 16, width: 200, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Main build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<DesignersBloc, DesignersState>(
        listener: (context, state) {
          if (state is DesignersLoaded) {
            allDesigners = state.designers;
            _groupDesigners(allDesigners);
          }
        },
        child: BlocBuilder<DesignersBloc, DesignersState>(
          builder: (context, state) {
            if (state is DesignersLoading) {
              return _buildShimmerList();
            } else if (state is DesignersLoaded) {
              if (groupedDesigners.isEmpty) {
                return const Center(child: Text("No designers found."));
              }

              return Column(
                children: [
                  // 🔍 Search box
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search designers...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),

                  // 🧾 Grouped designer list
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: groupedDesigners.length,
                      itemBuilder: (context, index) {
                        String firstLetter =
                        groupedDesigners.keys.elementAt(index);
                        List<Designer> designerList =
                        groupedDesigners[firstLetter]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              color: Colors.grey[200],
                              width: double.infinity,
                              child: Text(
                                firstLetter,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...designerList.map((designer) {
                              return ListTile(
                                title: Text(designer.name),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DesignerDetailScreen(
                                          designerName: designer.name),
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            // else if (state is DesignersError) {
            //   return Center(child: Text(state.message));
            // }

            else if (state is DesignersError) {
              // ✅ Check if it is a network error
              if (isNetworkError(state.message)) {
                return NoInternetWidget(
                  onRetry: () {
                    // ✅ Trigger the fetch event again
                    context.read<DesignersBloc>().add(FetchDesigners());
                  },
                );
              }
              // Normal error fallback
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// class DesignersViewBody extends StatefulWidget {
//   const DesignersViewBody({super.key});
//
//   @override
//   State<DesignersViewBody> createState() => _DesignersViewBodyState();
// }
//
// class _DesignersViewBodyState extends State<DesignersViewBody> {
//   final ScrollController _scrollController = ScrollController();
//   Map<String, List<Designer>> groupedDesigners = {};
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   /// Groups the list of designers alphabetically.
//   void _groupDesigners(List<Designer> designers) {
//     Map<String, List<Designer>> grouped = {};
//     for (var designer in designers) {
//       String firstLetter = designer.name[0].toUpperCase();
//       if (RegExp(r'^[0-9]').hasMatch(firstLetter)) firstLetter = '#';
//       grouped.putIfAbsent(firstLetter, () => []).add(designer);
//     }
//     if (mounted) {
//       setState(() {
//         groupedDesigners = Map.fromEntries(grouped.entries.toList()
//           ..sort((a, b) =>
//           a.key == '#' ? -1 : (b.key == '#' ? 1 : a.key.compareTo(b.key))));
//       });
//     }
//   }
//
//   /// Shimmer Widget for Loading State
//   Widget _buildShimmerList() {
//     return ListView.builder(
//       itemCount: 10,
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(height: 20, width: double.infinity, color: Colors.white),
//                 const SizedBox(height: 10),
//                 Container(height: 16, width: 200, color: Colors.white),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.white, // 🔥 Makes full screen white
//         body:
//     // This is the content that used to be inside the Scaffold's body.
//     BlocListener<DesignersBloc, DesignersState>(
//       listener: (context, state) {
//         if (mounted && state is DesignersLoaded) {
//           _groupDesigners(state.designers);
//         }
//       },
//       child: BlocBuilder<DesignersBloc, DesignersState>(
//         builder: (context, state) {
//           if (state is DesignersLoading) {
//             return _buildShimmerList();
//           } else if (state is DesignersLoaded) {
//             if (groupedDesigners.isEmpty) {
//               return const Center(child: Text("No designers found."));
//             }
//             return ListView.builder(
//               controller: _scrollController,
//               itemCount: groupedDesigners.length,
//               itemBuilder: (context, index) {
//                 String firstLetter = groupedDesigners.keys.elementAt(index);
//                 List<Designer> designerList = groupedDesigners[firstLetter]!;
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                       color: Colors.grey[200],
//                       width: double.infinity,
//                       child: Text(
//                         firstLetter,
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     ...designerList.map((designer) {
//                       return ListTile(
//                         title: Text(designer.name),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => DesignerDetailScreen(designerName: designer.name),
//                             ),
//                           );
//                         },
//                       );
//                     }).toList(),
//                   ],
//                 );
//               },
//             );
//           } else if (state is DesignersError) {
//             return Center(child: Text(state.message));
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     ));
//   }
// }