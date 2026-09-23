import 'package:flutter/material.dart';
import '../routing/route_names.dart';
import '../routing/route_generator.dart';

/// Top-level app router mapping routes to screens
class AppRouter {
  static const String initialRoute = RouteNames.splash;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return RouteGenerator.generateRoute(settings);
  }
}
