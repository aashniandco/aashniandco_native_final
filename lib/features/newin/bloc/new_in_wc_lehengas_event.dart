// new_in_accessories_event.dart
import 'package:equatable/equatable.dart';

abstract class NewInWcLehengasEvent extends Equatable {
  const NewInWcLehengasEvent();

  @override
  List<Object?> get props => [];
}

class FetchNewInWcLehengas extends NewInWcLehengasEvent {}
