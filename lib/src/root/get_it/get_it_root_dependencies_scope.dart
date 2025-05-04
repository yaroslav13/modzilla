import 'package:get_it/get_it.dart';
import 'package:modzilla/src/dependencies/dependencies_bundle.dart';
import 'package:modzilla/src/dependencies/get_it/get_it_dependencies_bundle.dart';
import 'package:modzilla/src/root/root_dependencies_scope.dart';

final class GetItRootDependenciesScope implements RootDependenciesScope<GetIt> {
  factory GetItRootDependenciesScope({
    required Future<void> Function(GetIt container) initializer,
  }) {
    _instance ??= GetItRootDependenciesScope._(initializer);
    return _instance!;
  }

  GetItRootDependenciesScope._(this.initializer);

  static GetItRootDependenciesScope? _instance;

  final Future<void> Function(GetIt container) initializer;

  final _container = GetIt.I;

  @override
  Future<void> dispose() async {
    await _container.reset();
  }

  @override
  Future<DependenciesBundle<GetIt>> init() async {
    await initializer(_container);
    return GetItDependenciesBundle(_container);
  }
}
