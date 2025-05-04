import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modzilla/src/dependencies/dependencies_bundle.dart';
import 'package:modzilla/src/root/root_dependencies_scope.dart';

final class RootDependenciesProvider extends StatefulWidget {
  const RootDependenciesProvider({
    required this.rootDependenciesScope,
    required this.child,
    super.key,
  });

  final RootDependenciesScope rootDependenciesScope;
  final Widget child;

  static DependenciesBundle of(BuildContext context) {
    return _DependenciesBundleProvider.of(context).bundle;
  }

  @override
  State<RootDependenciesProvider> createState() =>
      _RootDependenciesProviderState();
}

final class _RootDependenciesProviderState
    extends State<RootDependenciesProvider> {
  late Future<DependenciesBundle> _dependenciesInitializer;

  void _initDependencies() {
    _dependenciesInitializer = widget.rootDependenciesScope.init();
  }

  @override
  void initState() {
    super.initState();
    _initDependencies();
  }

  @override
  void didUpdateWidget(RootDependenciesProvider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.rootDependenciesScope != oldWidget.rootDependenciesScope) {
      unawaited(oldWidget.rootDependenciesScope.dispose());
      _initDependencies();
    }
  }

  @override
  void dispose() {
    unawaited(widget.rootDependenciesScope.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dependenciesInitializer,
      builder: (_, snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? _DependenciesBundleProvider(
                bundle: snapshot.requireData,
                child: widget.child,
              )
            : const SizedBox.shrink();
      },
    );
  }
}

final class _DependenciesBundleProvider extends InheritedWidget {
  const _DependenciesBundleProvider({
    required this.bundle,
    required super.child,
  });

  final DependenciesBundle bundle;

  static _DependenciesBundleProvider of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_DependenciesBundleProvider>()!;

  @override
  bool updateShouldNotify(_DependenciesBundleProvider oldWidget) {
    return bundle != oldWidget.bundle;
  }
}
