// class MegamenuModel {
//   final List<String> menuNames;
//
//   MegamenuModel({required this.menuNames});
//
//   factory MegamenuModel.fromJson(List<dynamic> json) {
//     // Assuming the first element is the actual list of menu names
//     final innerList = json.first as List<dynamic>;
//     return MegamenuModel(
//       menuNames: List<String>.from(innerList),
//     );
//   }
// }


class MegamenuItem {
  final String name;
  final String url;

  MegamenuItem({required this.name, required this.url});

  factory MegamenuItem.fromJson(Map<String, dynamic> json) {
    return MegamenuItem(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class MegamenuModel {
  // CHANGED: This is now a list of objects, not strings.
  // CHANGED: The variable name is 'menuItems', not 'menuNames'.
  final List<MegamenuItem> menuItems;

  MegamenuModel({required this.menuItems});

  factory MegamenuModel.fromJson(List<dynamic> json) {
    if (json.isEmpty) return MegamenuModel(menuItems: []);

    // The API returns a list inside a list: [[{...}, {...}]]
    final innerList = json.first as List<dynamic>;

    final items = innerList.map((item) {
      return MegamenuItem.fromJson(item as Map<String, dynamic>);
    }).toList();

    return MegamenuModel(menuItems: items);
  }
}