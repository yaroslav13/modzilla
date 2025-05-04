import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modzilla/src/dependencies/dependencies_factory.dart';
import 'package:modzilla/src/dependencies/dependencies_factory_provider.dart';
import 'package:modzilla/src/root/root_dependencies_scope.dart';

final class RootDependenciesProvider extends StatefulWidget {
  const RootDependenciesProvider({
    required this.rootDependenciesScope,
    required this.child,
    super.key,
  });

  final RootDependenciesScope rootDependenciesScope;
  final Widget child;

  @override
  State<RootDependenciesProvider> createState() =>
      _RootDependenciesProviderState();
}

final class _RootDependenciesProviderState
    extends State<RootDependenciesProvider> {
  late Future<DependenciesFactory> _dependenciesInitializer;

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
            ? DependenciesFactoryProvider(
                factory: snapshot.requireData,
                child: widget.child,
              )
            : const SizedBox.shrink();
      },
    );
  }
}
