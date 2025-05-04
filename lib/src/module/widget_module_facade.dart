import 'package:flutter/material.dart';
import 'package:modzilla/modzilla.dart';
import 'package:modzilla/src/module/module_bridge_widget.dart';

abstract base class WidgetModuleFacade {
  ModuleDependenciesScope get dependenciesScope;

  Widget buildModuleWidget(WidgetBuilder moduleWidgetBuilder) {
    return ModuleBridgeWidget(
      dependenciesScope: dependenciesScope,
      child: Builder(builder: moduleWidgetBuilder),
    );
  }
}
