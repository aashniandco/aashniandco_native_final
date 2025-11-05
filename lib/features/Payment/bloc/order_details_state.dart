import 'package:equatable/equatable.dart';

import '../model/order_details_model.dart';
import 'order_details_bloc.dart';

abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();

  @override
  List<Object> get props => [];
}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsSuccess extends OrderDetailsState {
  final OrderDetails order;


  const OrderDetailsSuccess(this.order);

  @override
  List<Object> get props => [order];
}

class OrderDetailsFailure extends OrderDetailsState {
  final String message;

  const OrderDetailsFailure(this.message);

  @override
  List<Object> get props => [message];
}