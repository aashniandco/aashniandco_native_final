import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/order_repository.dart';
import 'order_details_event.dart';
import 'order_details_state.dart';


class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  final OrderRepository _orderRepository;

  OrderDetailsBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrderDetailsInitial()) {
    on<FetchOrderDetails>(_onFetchOrderDetails);
  }

  Future<void> _onFetchOrderDetails(
      FetchOrderDetails event,
      Emitter<OrderDetailsState> emit,
      ) async {
    emit(OrderDetailsLoading());
    try {
      final orderDetails = await _orderRepository.fetchOrderDetails(event.orderId);
      emit(OrderDetailsSuccess(orderDetails));
    } catch (e) {
      emit(OrderDetailsFailure(e.toString()));
    }
  }
}