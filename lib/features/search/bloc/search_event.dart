

import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

// Event triggered when the user types in the search field
class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

// Event to clear the search results and return to initial state
class SearchCleared extends SearchEvent {
  const SearchCleared();
}