import 'package:flutter/material.dart';
import 'package:modzilla/src/root/root_dependencies_provider.dart';
import 'package:modzilla/src/root/root_dependencies_scope.dart';

final class DependenciesHost extends StatelessWidget {
  const DependenciesHost({
    required this.dependenciesScope,
    required this.child,
    super.key,
  });

  final RootDependenciesScope dependenciesScope;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RootDependenciesProvider(rootDependenciesScope: dependenciesScope, child: child);
  }
}
