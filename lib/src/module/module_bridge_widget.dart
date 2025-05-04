import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modzilla/modzilla.dart';

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
  late Future<void> _dependenciesInitializer;

  void _initDependencies() {
    _dependenciesInitializer = widget.dependenciesScope.initScope();
  }

  @override
  void initState() {
    super.initState();

    _initDependencies();
  }

  @override
  void dispose() {
    unawaited(widget.dependenciesScope.disposeScope());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dependenciesInitializer,
      builder: (_, snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? widget.child
            : const SizedBox.shrink();
      },
    );
  }
}
