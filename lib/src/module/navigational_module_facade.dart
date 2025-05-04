import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modzilla/modzilla.dart';
import 'package:modzilla/src/module/module_bridge_widget.dart';

typedef ModuleBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
);

abstract base class NavigationalModuleFacade {
  const NavigationalModuleFacade();

  ModuleDependenciesScope get dependenciesScope;

  ModuleNavigationConfigurator get navigationConfigurator;

  String get initialRoute => navigationConfigurator.initialRoute;

  ModuleBuilder get moduleBuilder;

  GoRoute buildModuleRouting({
    GlobalKey<NavigatorState>? rootNavigationKey,
    GlobalKey<NavigatorState>? parentNavigationKey,
  }) {
    return GoRoute(
      path: initialRoute,
      parentNavigatorKey:
          parentNavigationKey ?? navigationConfigurator.moduleNavigationKey,
      routes: navigationConfigurator.buildRoutes(
        rootNavigationKey,
        parentNavigationKey,
      ),
      builder: (context, state) => ModuleBridgeWidget(
        dependenciesScope: dependenciesScope,
        child: moduleBuilder(context, state),
      ),
    );
  }
}
