// abstract class AddressEvent {}
// class LoadAddresses extends AddressEvent {}

import 'package:equatable/equatable.dart';

import '../model/customer_address_model.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();
  @override
  List<Object> get props => [];
}

class LoadAddresses extends AddressEvent {}

class AddAddress extends AddressEvent {
  final CustomerAddress address;
  final String? region;
  final String? regionId;
  const AddAddress(this.address, {this.region, this.regionId}); // Update constructor


}
