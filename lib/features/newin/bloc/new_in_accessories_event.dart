// new_in_accessories_event.dart
import 'package:equatable/equatable.dart';

abstract class NewInAccessoriesEvent extends Equatable {
  const NewInAccessoriesEvent();

  @override
  List<Object?> get props => [];
}

class FetchNewInAccessories extends NewInAccessoriesEvent {}
