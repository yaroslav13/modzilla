import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modzilla/modzilla.dart';
import 'package:modzilla/src/root/root_dependencies_provider.dart';

final class ModuleBridgeWidget extends StatefulWidget {
  const ModuleBridgeWidget({
    required this.dependenciesScope,
    required this.child,
    super.key,
  });

  final ModuleDependenciesScope dependenciesScope;
  final Widget child;

  @override
  State<ModuleBridgeWidget> createState() => _ModuleBridgeWidgetState();
}

final class _ModuleBridgeWidgetState extends State<ModuleBridgeWidget> {
  void _initDependencies() {
    final bundle = RootDependenciesProvider.of(context);

    widget.dependenciesScope.pushScope(bundle);
  }

  Future<void> _disposeDependencies() async {
    final bundle = RootDependenciesProvider.of(context);

    await widget.dependenciesScope.disposeScope(bundle);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initDependencies(),
    );
  }

  @override
  void dispose() {
    unawaited(_disposeDependencies());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
