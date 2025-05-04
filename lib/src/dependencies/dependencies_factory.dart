import 'package:meta/meta.dart';

abstract interface class DependenciesFactory {
  @useResult
  T get<T extends Object>({String? instanceName});
}
