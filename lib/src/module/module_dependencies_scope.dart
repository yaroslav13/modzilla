import 'package:modzilla/src/dependencies/dependencies_bundle.dart';

abstract interface class ModuleDependenciesScope<T extends Object> {
  void pushScope(DependenciesBundle<T> bundle);

  Future<void> disposeScope(DependenciesBundle<T> bundle);
}
