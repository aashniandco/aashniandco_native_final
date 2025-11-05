class MegamenuModel {
  final List<String> menuNames;

  MegamenuModel({required this.menuNames});

  factory MegamenuModel.fromJson(List<dynamic> json) {
    // Assuming the first element is the actual list of menu names
    final innerList = json.first as List<dynamic>;
    return MegamenuModel(
      menuNames: List<String>.from(innerList),
    );
  }
}
