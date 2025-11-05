// lib/features/orders/bloc/order_details_event.dart

import 'package:equatable/equatable.dart';

abstract class OrderDetailsEvent extends Equatable {
  const OrderDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchOrderDetails extends OrderDetailsEvent {
  final int orderId;
  // final int orderEntityId;

  // ✅ CHANGE THE CONSTRUCTOR HERE
  // Add curly braces {} and the 'required' keyword.
   FetchOrderDetails({required this.orderId});

  @override
  List<Object> get props => [orderId];
}