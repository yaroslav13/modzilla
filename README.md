# Modularity

**`modularity`** is a module that will allow you to easily integrate DI into your modular architecture. 
It controls the lifecycle of module dependencies so you don't have to worry about it in every module. 
Modularity also allows you to easily integrate navigation into a modular architecture that supports 
the web with its navigation features. This solution supports three types of modules: with UI and 
navigation, only with UI and without UI, providing flexibility and control for any project requirements.

## 1. General API overview

**Modules types:**
1. Navigational module - a module that has internal navigation and the initial route, as the entry 
point to the module. This module integrating in application via navigation configuration and open like a regular route.
2. Widget module - a module that has no navigation, has at least one widget for integration into 
other modules. This module integrating in another modules like regular widgets.
3. Module without UI - module that has no UI, such as storages, services, utilities, etc. Integrated 
only via DI.

**Libraries:**

- [`root.dart`](modules/infrastructure/modularity/lib/root.dart) - contains export of the necessary classes for the modularity setup in root.

**Important:** `import 'package:modularity/root.dart'` only for root

- [`module.dart`](modules/infrastructure/modularity/lib/module.dart) - contains export of the necessary classes for the setup for modules with UI.

### 1.1. Root overview

- [InitRootDependenciesFunc](modules/infrastructure/modularity/lib/src/root/di_lifecycle/root_dependency_initializer.dart) - this function must be implemented in root. Its main responsibility 
is to initialize root dependencies and provide a configured `GetIt` instance.
- [DependenciesHostEntryPoint](modules/infrastructure/modularity/lib/src/root/dependencies_host_entry_point.dart) - is widget that designed to handle the initialization of application-wide 
dependencies at the start of your app and further control of the root dependency lifecycle in `modularity`.
- [GetItProvider](modules/infrastructure/modularity/lib/src/dependency/get_it_provider.dart) - widget that provides access to a `getIt` instance.

### 1.2. Module overview

- [InitScopeFunc](modules/infrastructure/modularity/lib/src/module/scope_lifecycle/scope_initializer.dart) - the primary purpose of this function is to facilitate the initialization 
of scoped dependencies within an application. In this context, a scope corresponds to a lifecycle 
segment of the application (like a module) where certain dependencies should only exist within that 
scope and be disposed when the scope ends. An implementation of this function is typically a generated 
function by `build_runner` and contains the registration of module dependencies inside `GetIt` for module scope.
- [ScopeInitializer](modules/infrastructure/modularity/lib/src/module/scope_lifecycle/scope_initializer.dart) - this interface is required to define a contract for initializing scoped 
dependencies by providing `scopeName` and `initScopeFunc`. This class must be implemented in every UI module 
that has internal dependencies or depend on other modules, since `ScopeInitializer` is used in the dependencies 
lifecycle control inside modularity.
- [GetItProvider](modules/infrastructure/modularity/lib/src/dependency/get_it_provider.dart) - widget that provides access to a getIt instance.
- [ModuleNavigationConfigurator](modules/infrastructure/modularity/lib/src/module/navigation/module_navigation_configurator.dart) - this interface ensures that each module can independently 
configure its own navigation logic. Necessary for further integration module's navigation into application navigation.
- [NavigationalModuleFacade](modules/infrastructure/modularity/lib/src/module/navigational_module_facade.dart) - abstract class for setting up navigation and DI within a modular architecture. 
The module with navigation must implement this class by providing an implementation of `ModuleNavigationConfigurator` 
and `ScopeInitializer`. Another module will use the implementation of this class to interact with this module.
- [WidgetModuleFacade](modules/infrastructure/modularity/lib/src/module/widget_module_facade.dart) - module with UI but without navigation must implement this class by providing
an implementation of `ScopeInitializer` and widgets that will be used in other modules. Another module 
will use the implementation of this class to interact with this module.

## 2. Root Setup

- Define a top-level function with type `InitRootDependenciesFunc` with `@InjectableInit` annotation.

**Note:** Global modules (which must live throughout the entire lifecycle of the app) or modules that
will be opened from root must be specified in `externalPackageModulesBefore/externalPackageModulesAfter`.

[Example](lib/src/di/root_dependency_initializer.dart):
```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:project_name/src/di/root_dependency_initializer.config.dart';

@InjectableInit(
  preferRelativeImports: false,
  asExtension: false,
  initializerName: r'$initRootDependencies',
)
Future<GetIt> initRootDependency() async => $initRootDependencies(GetIt.asNewInstance());
```

- Run `fvm flutter pub run build_runner build -d` in order for DI generate dart file with function 
that registered required dependencies.

- Wrap yor app widget with `DependenciesHostEntryPoint` and provide DI initialization function in it, 
so `modularity` can use it to initialize dependencies and add the configured GetIt instance to the widget tree.

[Example](lib/main.dart):
```dart
void main() {
  runApp(
    DependenciesHostEntryPoint(
      initDependenciesFunc: initRootDependency,
      child: const App(),
    ),
  );
}
```

- Create class that contains routes to the pages in root and/or initial pages of other modules that open from root.

[Example](lib/src/presentation/navigation/routes.dart):
```dart
abstract final class Routes {
  Routes._();

  static late final splash = FeatureModules.splashModule.initialRoute;
  static late final onboarding = FeatureModules.onboardingModule.initialRoute;
  static late final dashboard = FeatureModules.dashboardModule.initialRoute;
}
```

- Create another class with routes configuration which will be used to provide `MaterialApp` with router. 
Annotate it with `@lazySingleton` for it to register in DI.

[Example](lib/src/presentation/navigation/root_router_configurator.dart).

- Run `fvm flutter pub run build_runner build -d` in order for DI rebuild config file with new dependencies.
- Get router configuration from `GetItProvider` and pass it to `MaterialApp`.

[Example](lib/src/presentation/features/app.dart):
```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final routerConfigurator = GetItProvider.of(context).get<RootRouterConfigurator>();

    return MaterialApp.router(
      restorationScopeId: '',
      routerConfig: routerConfigurator.config,
    );
  }
}
```

## 3. Module with UI

### 3.1. Setup DI for module with UI

- Create class, that implement `MicroPackageModule` with `@InjectableInit` annotation

**Note:** If the module uses other modules, specify their `MicroPackageModule` implementation in
`externalPackageModulesBefore/externalPackageModulesAfter`.

**Important:** Specify the name of the scope of current module in `ExternalModule` and for all
dependencies inside module in annotation such as `@Singleton` or `@Inject`. This is necessary so
that the dependencies required by this module are registered when the module is opened and
unregistered when the module is closed.

[Example](modules/features/settings/lib/src/di/settings_micro_package_module.dart):
```dart
const _settingsScope = 'settings';

@InjectableInit(
  preferRelativeImports: false,
  asExtension: false,
  initializerName: r'$registerModule',
  externalPackageModulesBefore: [
    ExternalModule(UserServiceMicroPackageModule, scope: _settingsScope),
    ExternalModule(SupportMicroPackageModule, scope: _settingsScope),
  ],
)
final class SettingsMicroPackageModule extends MicroPackageModule {
  @override
  FutureOr<void> init(GetItHelper gh) => $registerModule(gh.getIt);
}
```

- Run command `fvm flutter packages pub run build_runner build -d` inside current module.
This should generate two functions: `$registerModule` and `initSampleNameScope` (in case module depends
on other modules and/or has its own dependencies) in file [`***.config.dart`](modules/features/settings/lib/src/di/settings_micro_package_module.config.dart).
The first function was used in the implementation of `MicroPackageModule`, the second one is 
necessary for controlling a lifecycle of module dependencies and will be used in the next step.
- Create class that implement `ScopeInitializer`. Use the previously mentioned `initSampleNameScope` 
function in implementation of `initScopeFunc`.

[Example](modules/features/settings/lib/src/di/settings_scope_initializer.dart): 
```dart
final class SettingsScopeInitializer implements ScopeInitializer {
  static const settingsScope = 'settings';

  @override
  InitScopeFunc get initScopeFunc => initSettingsScope;

  @override
  String get scopeName => settingsScope;
}
```

### 3.2. Setup module with navigation

- Create class that contains all routes to the pages in module

[Example](modules/features/settings/lib/src/presentation/navigation/routes.dart):
```dart
abstract final class Routes {
  Routes._();

  static const settings = _SettingsRoute();
  static const languageOption = _LocalizationRoute();
  //....
}

final class _SettingsRoute extends NamedRoute {
  const _SettingsRoute()
      : super(pathPatternFragment: '/settings', name: 'settings');
}

final class _LocalizationRoute extends NamedRoute {
  const _LocalizationRoute()
      : super(pathPatternFragment: 'language', name: 'language');
}

//....
```

- Create class that implement `ModuleNavigationConfigurator`:
    - `BaseRoute get initialRoute` - this property should define what the first screen or component 
       the user sees when navigating to this module
    - `List<RouteBase> buildRoutes()` - this method is responsible for building and returning a list 
       of routes that the module can handle.

[Example](modules/features/settings/lib/src/presentation/navigation/navigation_configurator.dart):
```dart
final class SettingsNavigationConfigurator implements ModuleNavigationConfigurator {
  @override
  GlobalKey<NavigatorState> get moduleNavigationKey => GlobalKey<NavigatorState>(debugLabel: 'settings');

  @override
  BaseRoute get initialRoute => Routes.settings;

  @override
  List<RouteBase> buildRoutes(GlobalKey<NavigatorState>? parentNavigationKey) {
    return [
      _buildSettingsRoute(),
    ];
  }

  GoRoute _buildSettingsRoute() {
    return buildRoute(
      route: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
      routes: [
        _buildLanguageRoute(),
        //....
      ],
    );
  }

  //....
}
```

- Create class that implement `NavigationalModuleFacade`

**Note:** You can override `moduleBuilder` with type  `Widget Function(BuildContext context, Widget child)`
for translation, overlay, etc. This wrapper applies to all screens in the module.

[Example](modules/features/settings/lib/src/settings_module_facade.dart):
```dart
final class SettingsModuleFacade extends NavigationalModuleFacade {
  @override
  ModuleNavigationConfigurator get navigationConfigurator => SettingsNavigationConfigurator();

  @override
  ScopeInitializer? get scopeInitializer => SettingsScopeInitializer();

  @override
  ModuleBuilder get moduleBuilder => (context, child) => TranslationProvider(child: child);
}
```

### 3.3. Setup widget module without navigation

- Create class that implement `WidgetModuleFacade`. Provide widgets that will be used in other modules. 
Each widget must be wrapped in a `buildModuleWidget` function which takes `WidgetBuilder` as a parameter.
This is necessary to have control over the lifecycle of the scope dependencies.

[Example](modules/features/catalog/lib/src/catalog_module_facade.dart):
```dart
final class CatalogModuleFacade extends WidgetModuleFacade {
  @override
  ScopeInitializer? get scopeInitializer => CatalogScopeInitializer();

  Widget get catalogPanel => buildModuleWidget((context) => const CatalogPanel());

  Widget get catalogTable => buildModuleWidget((context) => const CatalogTable());
}
```

## 4. Integrating module with UI

- Add `MicroPackageModule` to `externalPackageModulesBefore/externalPackageModulesAfter` in
`@InjectableInit` annotation.

[Example in module](modules/features/dashboard/lib/src/di/dashboard_micro_package_module.dart)
```dart
const _dashboardScope = DashboardScopeInitializer.dashboardScope;

@InjectableInit(
  preferRelativeImports: false,
  asExtension: false,
  initializerName: r'$registerModule',
  externalPackageModulesBefore: [
    //...
    ExternalModule(SettingsMicroPackageModule, scope: _dashboardScope),
  ],
)
final class DashboardMicroPackageModule extends MicroPackageModule {
  @override
  FutureOr<void> init(GetItHelper gh) => $registerModule(gh.getIt);
}
```

[Example in root](lib/src/di/root_dependency_initializer.dart):
```dart
@InjectableInit(
  preferRelativeImports: false,
  asExtension: false,
  initializerName: r'$initRootDependencies',
  externalPackageModulesAfter: [
    ExternalModule(SettingsMicroPackageModule),
  ],
)
Future<GetIt> initRootDependency() async => $initRootDependencies(GetIt.asNewInstance());
```

- Run `fvm flutter pub run build_runner build -d` in order for DI rebuild config file and add module
dependencies to it.

- Create class that contains instances of module facade

[Example](modules/features/dashboard/lib/src/presentation/feature_modules.dart):
```dart
abstract class FeatureModules {
  FeatureModules._();

  static late final settingsModule = SettingsModuleFacade();
  
  //....
}
```

### 4.1. For navigational module
- Use `FeatureModules.sampleModuleName.initialRoute` to declare entry point route of module.

[Example](modules/features/dashboard/lib/src/presentation/navigation/routes.dart):
```dart
abstract final class Routes {
  Routes._();
  
  static late final settings = FeatureModules.settingsModule.initialRoute;
}
```
- Add routes of module to navigation configuration by calling `buildModuleRouting()` on module
facade instance

[Example](modules/features/dashboard/lib/src/presentation/navigation/navigation_configurator.dart):
```dart
final class DashboardNavigationConfigurator implements ModuleNavigationConfigurator {
  //....
  
  @override
  List<RouteBase> buildRoutes(GlobalKey<NavigatorState>? parentNavigationKey) {
    return [
      _buildDashboardRoute(
        parentNavigationKey: parentNavigationKey,
        routes: [
          //.....
          _buildSettingsRoutes(),
        ],
      ),
    ];
  }

  //...

  ShellRoute _buildSettingsRoutes() {
    return FeatureModules.settingsModule.buildModuleRouting();
  }
}
```
- After that you can navigate to the module as to a regular route, for example
`navigationController.navigate([Routes.settings])`

### 4.2. For widget module
- Add widget to screen, from instance of module facade: `FeatureModules.sampleModuleName.widgetName`

[Example](modules/features/dashboard/lib/src/presentation/features/home/home_screen.dart):
```dart
class HomeScreen extends HookWidget {
  
  @override
  Widget build(BuildContext context) {
    //....
    return Scaffold(
      body: Row(
        children: [
          _buildCard(FeatureModules.catalogModule.catalogPanel),
          // ....
        ],
      ),
    );
  }
  
  //...
  
  Widget _buildCard(Widget child) {
    //....
  }
}
```

## 5. Module without UI

### 5.1 Setup module without UI
Create class, that implement `MicroPackageModule` with `@InjectableInit` annotation

**Note:** If the module uses other modules, specify their MicroPackageModule implementation in
`externalPackageModulesBefore/externalPackageModulesAfter`.

**Important:** DON'T specify any scope for modules in `ExternalModule` or for dependencies inside
module. Dependency lifecycle of module without UI is controlled by the module with UI that uses this
module.

[Example](modules/services/user_service/lib/src/di/user_service_micro_package_module.dart):
```dart
@InjectableInit(
  preferRelativeImports: false,
  asExtension: false,
  initializerName: r'$registerModule',
  externalPackageModulesBefore: [
    ExternalModule(LocalStorageMicroPackageModule),
  ],
)
final class UserServiceMicroPackageModule extends MicroPackageModule {
  @override
  FutureOr<void> init(GetItHelper gh) async => $registerModule(gh.getIt);
}
```
Run command `fvm flutter packages pub run build_runner build -d` inside current module to
generate config file with function that register module dependencies.

### 5.2. Integrating module without UI

- Add `MicroPackageModule` to `externalPackageModulesBefore/externalPackageModulesAfter` in
`@InjectableInit` annotation.

- Run `fvm flutter pub run build_runner build` in order for DI rebuild config file and add
module dependencies to it.