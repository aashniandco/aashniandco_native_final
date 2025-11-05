// home_screen_banner_state.dart

import '../../newin/model/new_in_model.dart';

abstract class HomeScreenBannerState {}

class HomeScreenBannerLoading extends HomeScreenBannerState {}

class HomeScreenBannerLoaded extends HomeScreenBannerState {
  final List<Product> products;

  // ✅ Use named parameter
  HomeScreenBannerLoaded({required this.products});
}

class HomeScreenBannerError extends HomeScreenBannerState {
  final String message;

  HomeScreenBannerError(this.message);
}
