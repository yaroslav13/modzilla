import 'package:meta/meta.dart';

abstract interface class DependenciesFactory {
  @useResult
  D get<D extends Object>({String? instanceName});
}
