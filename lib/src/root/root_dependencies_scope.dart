import 'dart:async';

import 'package:modzilla/src/dependencies/dependencies_bundle.dart';

typedef ScopeDisposer = Future<void> Function();

abstract interface class RootDependenciesScope<T extends Object> {
  Future<DependenciesBundle<T>> init();

  Future<void> dispose();
}
