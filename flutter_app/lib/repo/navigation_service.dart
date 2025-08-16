import 'package:flutter/widgets.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> _navigationKey =
      GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  NavigatorState get navigator => _navigationKey.currentState!;

  BuildContext get navigatorContext => _navigationKey.currentContext!;
}
