import '../repository/order_history_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'address_event.dart';
import 'address_state.dart';

// class AddressBloc extends Bloc<AddressEvent, AddressState> {
//   final OrderHistoryRepository repository;
//
//   AddressBloc(this.repository) : super(AddressInitial()) {
//     on<LoadAddresses>((event, emit) async {
//       emit(AddressLoading());
//       try {
//         final addresses = await repository.fetchAddresses();
//         emit(AddressLoaded(addresses));
//       } catch (e) {
//         emit(AddressError(e.toString()));
//       }
//     });
//   }
// }

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final OrderHistoryRepository _repository;

  AddressBloc(this._repository) : super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<AddAddress>(_onAddAddress);
  }

  Future<void> _onLoadAddresses(LoadAddresses event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final addresses = await _repository.fetchAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onAddAddress(AddAddress event, Emitter<AddressState> emit) async {
    // Let the UI know we are saving
    emit(AddressSaving());
    try {
      final success = await _repository.saveAddress(event.address, region: event.region, regionId: event.regionId);
      if (success) {
        // If saving was successful, reload all addresses to update the UI
        add(LoadAddresses());
      } else {
        emit(const AddressError("An unknown error occurred while saving."));
      }
    } catch (e) {
      emit(AddressError("Failed to save address: ${e.toString()}"));
    }
  }
}