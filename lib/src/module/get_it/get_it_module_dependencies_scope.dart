import 'package:get_it/get_it.dart';
import 'package:modzilla/src/dependencies/dependencies_bundle.dart';
import 'package:modzilla/src/module/module_dependencies_scope.dart';

final class GetItModuleDependenciesScope
    implements ModuleDependenciesScope<GetIt> {
  const GetItModuleDependenciesScope({
    required this.scopeName,
    required this.initializer,
  });

  final String scopeName;
  final Future<void> Function(GetIt container) initializer;

  @override
  Future<void> disposeScope(DependenciesBundle<GetIt> bundle) async {
    final getIt = bundle.dependenciesContainer;
    await getIt.popScope();
  }

  @override
  void pushScope(DependenciesBundle<GetIt> bundle) {
    bundle.dependenciesContainer.pushNewScope(
      scopeName: scopeName,
      init: initializer,
    );
  }
}
