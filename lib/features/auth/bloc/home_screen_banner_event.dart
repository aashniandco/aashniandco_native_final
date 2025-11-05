// home_screen_banner_event.dart
abstract class HomeScreenBannerEvent {}

class FetchHomeScreenBanner extends HomeScreenBannerEvent {
  final int id;
  final String bannerName;



  FetchHomeScreenBanner( {required this.id,required this.bannerName});
}
