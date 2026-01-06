import '../model/megamenu_model.dart';

abstract class MegamenuState {}

class MegamenuInitial extends MegamenuState {}

class MegamenuLoading extends MegamenuState {}

// class MegamenuLoaded extends MegamenuState {
//   final List<String> menuNames;
//   MegamenuLoaded(this.menuNames);
// }

class MegamenuLoaded extends MegamenuState {
  // UPDATED: Holds list of custom objects now
  final List<MegamenuItem> menuItems;

  MegamenuLoaded(this.menuItems);
}


class MegamenuError extends MegamenuState {
  final String message;
  MegamenuError(this.message);
}
