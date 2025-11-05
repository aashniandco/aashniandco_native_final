part of 'designers_bloc.dart';

abstract class DesignersState extends Equatable {
  @override
  List<Object> get props => [];
}

class DesignersLoading extends DesignersState {}

class DesignersLoaded extends DesignersState {
  final List<Designer> designers;
  DesignersLoaded(this.designers);

  @override
  List<Object> get props => [designers];
}

class DesignersError extends DesignersState {
  final String message;
  DesignersError(this.message);

  @override
  List<Object> get props => [message];
}

