import 'package:get_it/get_it.dart';
import 'package:modzilla/src/dependencies/dependencies_bundle.dart';

final class GetItDependenciesBundle implements DependenciesBundle<GetIt> {
  const GetItDependenciesBundle(this.dependenciesContainer);

  @override
  final GetIt dependenciesContainer;

  @override
  D get<D extends Object>({String? instanceName}) {
    return dependenciesContainer.get<D>(instanceName: instanceName);
  }
}
