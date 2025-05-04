abstract interface class ModuleDependenciesScope {
  Future<void> initScope();

  Future<void> disposeScope();
}
