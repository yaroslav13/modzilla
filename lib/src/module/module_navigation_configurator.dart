import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract interface class ModuleNavigationConfigurator {
  GlobalKey<NavigatorState> get moduleNavigationKey;

  String get initialRoute;

  List<RouteBase> buildRoutes(
    GlobalKey<NavigatorState>? rootNavigationKey,
    GlobalKey<NavigatorState>? parentNavigationKey,
  );
}
