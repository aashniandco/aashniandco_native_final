abstract class MegamenuState {}

class MegamenuInitial extends MegamenuState {}

class MegamenuLoading extends MegamenuState {}

class MegamenuLoaded extends MegamenuState {
  final List<String> menuNames;
  MegamenuLoaded(this.menuNames);
}

class MegamenuError extends MegamenuState {
  final String message;
  MegamenuError(this.message);
}
