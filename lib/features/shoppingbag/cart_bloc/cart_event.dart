// abstract class CartEvent {}
//
// class FetchCartItems extends CartEvent {}
//
// class FetchGuestCartItems extends CartEvent {}
//
// class RemoveCartItem extends CartEvent {
//   final int itemId;
//   RemoveCartItem(this.itemId);
// }
//
// class UpdateCartItemQty extends CartEvent {
//   final int itemId;
//   final int newQty;
//   UpdateCartItemQty(this.itemId, this.newQty);
// }



abstract class CartEvent {}

class FetchCartItems extends CartEvent {}

class RemoveCartItem extends CartEvent {
  final int itemId;
  RemoveCartItem(this.itemId);
}

class UpdateCartItemQty extends CartEvent {
  final int itemId;
  final int newQty;
  UpdateCartItemQty(this.itemId, this.newQty);
}


class ApplyCoupon extends CartEvent {
  final String couponCode;
  ApplyCoupon(this.couponCode);
  @override
  List<Object> get props => [couponCode];
}

class RemoveCoupon extends CartEvent {
  RemoveCoupon();
}

class ClearCouponError extends CartEvent {}