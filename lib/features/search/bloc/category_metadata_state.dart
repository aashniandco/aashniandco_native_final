



import 'package:equatable/equatable.dart';

abstract class CategoryMetadataState extends Equatable {
  const CategoryMetadataState();
  @override
  List<Object> get props => [];
}

class CategoryMetadataInitial extends CategoryMetadataState {}

class CategoryMetadataLoading extends CategoryMetadataState {}

class CategoryMetadataLoadSuccess extends CategoryMetadataState {
  final Map<String, dynamic> metadata;

  const CategoryMetadataLoadSuccess({required this.metadata});

  @override
  List<Object> get props => [metadata];
}

class CategoryMetadataLoadFailure extends CategoryMetadataState {
  final String error;

  const CategoryMetadataLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}