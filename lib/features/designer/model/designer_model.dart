
// class Designer {
//   final String name;
//
//   Designer({required this.name});
//
//   factory Designer.fromJson(dynamic json) {
//     if (json is String) {
//       return Designer(name: json);
//     } else if (json is Map<String, dynamic>) {
//       return Designer(name: json['name'] ?? '');
//     } else {
//       throw Exception("Invalid designer json: $json");
//     }
//   }
// }

class Designer {
  final String name;

  Designer({required this.name});
}


//18/8/2025
// class Designer {
  //   final String name;
  //
  //   Designer({required this.name});
  //
  //   factory Designer.fromJson(String jsonName) {
  //     return Designer(name: jsonName);
  //   }
  // }

  // class Designer {
  //   final String name;
  //
  //   // A simple constructor that takes the name directly.
  //   Designer({required this.name});
  // }
