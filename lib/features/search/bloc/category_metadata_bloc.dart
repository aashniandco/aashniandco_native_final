
import 'package:equatable/equatable.dart';

import '../../categories/repository/api_service.dart';
import 'category_metadata_event.dart';
import 'category_metadata_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import your ApiService and the events/states
// import 'package:your_app/services/api_service.dart';



class CategoryMetadataBloc extends Bloc<CategoryMetadataEvent, CategoryMetadataState> {
  final ApiService _apiService;

  CategoryMetadataBloc({required ApiService apiService})
      : _apiService = apiService,
        super(CategoryMetadataInitial()) {
    on<FetchCategoryMetadata>(_onFetchCategoryMetadata);
  }

  Future<void> _onFetchCategoryMetadata(
      FetchCategoryMetadata event,
      Emitter<CategoryMetadataState> emit,
      ) async {
    emit(CategoryMetadataLoading());
    try {
      final metadata = await _apiService.fetchCategoryMetadataByName(event.categorySlug);
      emit(CategoryMetadataLoadSuccess(metadata: metadata));
    } catch (e) {
      emit(CategoryMetadataLoadFailure(error: e.toString()));
    }
  }
}