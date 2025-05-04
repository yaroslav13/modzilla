import 'package:flutter/material.dart';
import 'package:modzilla/src/dependencies/dependencies_factory.dart';

final class DependenciesFactoryProvider extends StatelessWidget {
  const DependenciesFactoryProvider({
    required this.factory,
    required this.child,
    super.key,
  });

  final DependenciesFactory factory;
  final Widget child;

  static DependenciesFactory of(BuildContext context) {
    return _DependenciesFactoryProvider.of(context).factory;
  }

  @override
  Widget build(BuildContext context) {
    return _DependenciesFactoryProvider(factory: factory, child: child);
  }
}

final class _DependenciesFactoryProvider extends InheritedWidget {
  const _DependenciesFactoryProvider({
    required this.factory,
    required super.child,
  });

  final DependenciesFactory factory;

  static _DependenciesFactoryProvider of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_DependenciesFactoryProvider>()!;

  @override
  bool updateShouldNotify(_DependenciesFactoryProvider oldWidget) {
    return factory != oldWidget.factory;
  }
}
