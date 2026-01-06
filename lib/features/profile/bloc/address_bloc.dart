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

// class AddressBloc extends Bloc<AddressEvent, AddressState> {
//   final OrderHistoryRepository _repository;
//
//   AddressBloc(this._repository) : super(AddressInitial()) {
//     on<LoadAddresses>(_onLoadAddresses);
//     on<AddAddress>(_onAddAddress);
//   }
//
//
//
//
//
//
//   Future<void> _onLoadAddresses(LoadAddresses event, Emitter<AddressState> emit) async {
//     emit(AddressLoading());
//     try {
//       final addresses = await _repository.fetchAddresses();
//       emit(AddressLoaded(addresses));
//     } catch (e) {
//       emit(AddressError(e.toString()));
//     }
//   }
//
//   Future<void> _onAddAddress(AddAddress event, Emitter<AddressState> emit) async {
//     // Let the UI know we are saving
//     emit(AddressSaving());
//     try {
//       final success = await _repository.saveAddress(event.address, region: event.region, regionId: event.regionId);
//       if (success) {
//         // If saving was successful, reload all addresses to update the UI
//         add(LoadAddresses());
//       } else {
//         emit(const AddressError("An unknown error occurred while saving."));
//       }
//     } catch (e) {
//       emit(AddressError("Failed to save address: ${e.toString()}"));
//     }
//   }
// }

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final OrderHistoryRepository _repository;

  AddressBloc(this._repository) : super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<AddAddress>(_onAddAddress);
    on<DeleteAddress>(_onDeleteAddress); // Moved logic to a separate method for cleanliness
  }

  // --- HANDLER: LOAD ---
  Future<void> _onLoadAddresses(LoadAddresses event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final addresses = await _repository.fetchAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  // --- HANDLER: ADD / UPDATE ---
  Future<void> _onAddAddress(AddAddress event, Emitter<AddressState> emit) async {
    emit(AddressSaving());
    try {
      bool success;

      // If ID is 0, it's a NEW address. If ID > 0, it's an UPDATE.
      if (event.address.id == 0) {
        success = await _repository.saveAddress(
            event.address,
            region: event.region,
            regionId: event.regionId
        );
      } else {
        success = await _repository.updateAddress( // <-- Calls the new method
            event.address,
            region: event.region,
            regionId: event.regionId
        );
      }

      if (success) {
        add(LoadAddresses());
      } else {
        emit(const AddressError("An unknown error occurred while saving."));
      }
    } catch (e) {
      emit(AddressError("Failed to save address: ${e.toString()}"));
    }
  }

  // --- HANDLER: DELETE ---
  Future<void> _onDeleteAddress(DeleteAddress event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final success = await _repository.deleteAddress(event.addressId);
      if (success) {
        add(LoadAddresses()); // Reload list after deletion
      } else {
        emit(const AddressError("Failed to delete address."));
      }
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
} // All methods MUST be inside this closing brace

class DeleteAddress extends AddressEvent {
  final int addressId;
  DeleteAddress(this.addressId);
}