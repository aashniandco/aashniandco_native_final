import 'package:aashniandco/features/search/bloc/search_event.dart';
import 'package:aashniandco/features/search/bloc/search_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart'; // For debounce
import 'package:aashniandco/features/search/data/models/search_results_model.dart';
import '../data/repositories/search_repository.dart';



// Debounce transformer
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) {
    return events.debounceTime(duration).asyncExpand(mapper);
  };
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;

  SearchBloc({required SearchRepository searchRepository})
      : _searchRepository = searchRepository,
        super(SearchInitial()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      // Apply a 300ms debounce to the event
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<SearchCleared>(_onSearchCleared);
  }

  Future<void> _onSearchQueryChanged(
      SearchQueryChanged event,
      Emitter<SearchState> emit,
      ) async {
    final query = event.query;

    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      // The repository now returns the complete SearchResults object
      final searchResults = await _searchRepository.searchProducts(query);
      // Pass the whole object to the success state
      emit(SearchSuccess(searchResults));
    } catch (e) {
      emit(SearchFailure(e.toString()));
    }
  }
  }

  void _onSearchCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(SearchInitial());

}