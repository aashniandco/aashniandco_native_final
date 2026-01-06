import 'package:flutter/material.dart';

class NavigationService {
  // ✅ Global key to allow navigation without context
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}
