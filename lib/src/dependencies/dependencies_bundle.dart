import 'package:modzilla/src/dependencies/dependencies_factory.dart';

abstract interface class DependenciesBundle<T extends Object>
    implements DependenciesFactory {
  T get dependenciesContainer;
}
