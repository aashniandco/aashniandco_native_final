// part of 'new_in_bloc.dart';
// @immutable
// abstract class NewInEvent {}
//
// class FetchNewIn extends NewInEvent {
//   final int page;
//
//   FetchNewIn({this.page = 0}); // default page = 0
// }
//
//
//
//



part of 'new_in_bloc.dart';

abstract class NewInEvent extends Equatable {
  const NewInEvent();

  @override
  List<Object> get props => [];
}

// The single event to handle initial fetch, sort changes, and pagination.
class FetchNewInProducts extends NewInEvent {
  final String sortOption;
  final bool isReset;

  const FetchNewInProducts({
    required this.sortOption,
    this.isReset = false,
  });

  @override
  List<Object> get props => [sortOption, isReset];
}