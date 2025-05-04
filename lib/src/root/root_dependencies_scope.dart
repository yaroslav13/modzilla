import 'dart:async';

import 'package:modzilla/src/dependencies/dependencies_factory.dart';

typedef ScopeDisposer = Future<void> Function();

abstract interface class RootDependenciesScope {
  Future<DependenciesFactory> init();

  Future<void> pushNewScope(String name, Future<void> Function() init);

  Future<void> popScope(String name);

  Future<void> dispose();
}
