import 'package:equatable/equatable.dart';

import '../model/customer_address_model.dart';

// abstract class AddressState {}
// class AddressInitial extends AddressState {}
// class AddressLoading extends AddressState {}
// class AddressLoaded extends AddressState {
//   final List<CustomerAddress> addresses;
//   AddressLoaded(this.addresses);
// }
// class AddressError extends AddressState {
//   final String message;
//   AddressError(this.message);
// }


abstract class AddressState extends Equatable {
  const AddressState();
  @override
  List<Object> get props => [];
}

class AddressInitial extends AddressState {}
class AddressLoading extends AddressState {}

// A specific state for when an address is being saved
class AddressSaving extends AddressState {}

class AddressLoaded extends AddressState {
  final List<CustomerAddress> addresses;
  const AddressLoaded(this.addresses);

  @override
  List<Object> get props => [addresses];
}

class AddressError extends AddressState {
  final String message;
  const AddressError(this.message);

  @override
  List<Object> get props => [message];
}