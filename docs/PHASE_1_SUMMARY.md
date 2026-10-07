# Phase 1 — Foundation

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 1, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions built the same foundation.

---

## 🎯 Phase Goal

Phase 1 lays the **foundation** every later feature stands on. Before writing any movie logic, a production-quality Flutter app needs:

- a **reproducible toolchain**: everyone builds with the same Flutter version;
- strict **static analysis** from the first line of code;
- a layered **folder structure**, so every class has an obvious home;
- a small **design system**, so every screen looks consistent in light and dark mode;
- **type-safe navigation** with a separate back stack per tab;
- a **composition root** for dependency injection, so the app stays testable;
- an app **shell** that runs end to end, with **tests** proving the navigation contract.

Nothing here is movie-specific yet; it's the skeleton.

---

## 🧱 What Was Implemented

- **Project & toolchain**
  - Created with `fvm spawn 3.47.6 create --org co.bitfuse.flutter --project-name movie_explorer --platforms android,ios`.
  - Pinned with `fvm use 3.47.6`, which writes `.fvmrc` (committed) and adds `.fvm/` to `.gitignore`.
  - Migrated to the standalone **`material_ui`** package with `dart fix --apply --code=migrate_design_widgets`; `cupertino_icons` removed (Material icons only).
  - The Flutter 3.47 template defaults stay: iOS 15 minimum, Swift Package Manager for iOS plugins, and AGP 9.1 / Gradle 9.3.1 / Kotlin 2.4 for Android.
- **Static analysis**
  - `flutter_lints` plus the strict analyzer modes `strict-casts`, `strict-inference` and `strict-raw-types`.
  - Extra rules: package imports only, const constructors, final locals, `unawaited_futures`, and closing streams and subscriptions.
  - Generated code is excluded.
- **Folder structure:** `app/`, `core/{common,design_system,navigation,network,database,storage}`, `data/{mapper,repository}`, `domain/{model,repository,usecase}`, `features/{home,search,favorites,details,settings}` and `di/`. Folders for later phases are kept in git with `.gitkeep`.
- **Design system** (`core/design_system/`)
  - `AppTheme`: Material 3 light/dark themes from one seed (`#4D5CE6`, the iOS brand color), using the `fidelity` scheme variant so the brand color isn't muted.
  - `AppColors`: a `ThemeExtension` with the `favorite`, `ratingStar` and `badgeScrim` tokens, plus a `context.appColors` shorthand.
  - Tokens: `AppSpacing`, `AppRadius` and `AppIconSize`, named like the iOS `Theme` constants.
  - Shared state widgets: `LoadingView`, `ErrorView` (message + optional retry) and `EmptyStateView` (icon, title, message, optional action).
  - A barrel file, `design_system.dart`, so features need one import.
- **Typed navigation** (`core/navigation/`)
  - `app_routes.dart`: one `@TypedStatefulShellRoute` with **four branches** (Home, Search, Favorites, Settings), each with a named navigator key.
  - Details is declared as a child route of each list tab: `/home/movie/:id`, `/search/movie/:id` and `/favorites/movie/:id`. `go_router_builder` generates `app_routes.g.dart`.
  - `createAppRouter()`:
    - a router *factory* (not a global);
    - `initialLocation` `/home`;
    - a redirect from `/` to Home;
    - a friendly "Page not found" screen.
  - `AppShell`: a `Scaffold` with a Material 3 `NavigationBar`; re-tapping the active tab pops it to its root.
- **Dependency injection:** `configureDependencies()` in `di/injection.dart` is the `get_it` + `injectable` composition root, awaited in `main()`. It is intentionally empty until Phase 2 registers the first services.
- **App root:** `MovieExplorerApp` is a `StatefulWidget` that owns the router and disposes it, and builds `MaterialApp.router` with the light/dark themes.
- **Placeholder screens:**
  - Home ("Trending"), Search, Favorites and Settings, plus a Details page that shows the id it received.
  - The list tabs have a temporary **"Open sample details"** button that pushes their typed Details route; it goes away once real screens arrive.
- **Tests:** 15 tests across navigation, theme and the shared state widgets.
- **Docs:** the first `README.md` and this summary.

The app **builds for Android and iOS** and shows the four tabs, each with its own back stack.

---

## 💙 Flutter / Dart Concepts Demonstrated

Only concepts introduced in this phase:

- **FVM per-project pinning:** `.fvmrc` makes the Flutter version part of the repo, just as the Gradle wrapper does on Android.
- **Flutter 3.47's `material_ui` package:** Material moved out of the core SDK into a standalone package. `dart fix` *data-driven fixes* migrate the imports automatically.
- **Material 3 theming**
  - `ColorScheme.fromSeed` and `DynamicSchemeVariant`.
  - `ThemeData` component themes.
  - `ThemeExtension` (with `copyWith` and `lerp`) for app-specific design tokens.
  - A `BuildContext` extension for ergonomic access.
- **Dart 3 class modifiers:** `abstract final class` as a non-instantiable, non-extendable namespace for constants, and `final class` for a closed value type.
- **Declarative routing with `go_router`:** `GoRouter`, top-level `redirect`, `errorBuilder`, and `MaterialApp.router(routerConfig:)`.
- **Typed routes via code generation:**
  - `@TypedGoRoute` / `@TypedStatefulShellRoute` with `GoRouteData` classes and generated mixins;
  - path parameters parsed into an `int`;
  - the generated `location`, `go()` and `push()`.
- **`StatefulShellRoute.indexedStack`**
  - One `Navigator` per tab, with inactive tabs kept alive offstage (`Offstage` + `TickerMode`).
  - `StatefulNavigationShell.goBranch(index, initialLocation:)` for tab switching and re-tap-to-pop.
- **Service locator + generated DI:** `GetIt.instance`, `@InjectableInit`, and the generated `init()` extension.
- **`build_runner` and `part` files:** how annotations turn into committed, generated Dart code.
- **Owning disposable resources:** the router is created in `State` and released in `dispose()`, instead of living in a global.
- **Widget testing**
  - `pumpWidget` / `pumpAndSettle`.
  - Finders (`find.descendant`, `find.widgetWithText`, `find.byType`) and how they skip offstage widgets.
  - Test helpers as `WidgetTester` extensions.
- **Analyzer strict modes:** catching implicit `dynamic` and unsafe casts at compile time.

---

## 🔁 Data Flow (this phase)

Navigation is the only "flow" wired up so far:

```
Tap a NavigationBar destination ──▶ AppShell._onDestinationSelected(i)
                                       │  navigationShell.goBranch(i, initialLocation: i == current)
                                       ▼
                 StatefulNavigationShell (IndexedStack of 4 Navigators)
                                       │  shows branch i; the others stay alive offstage
                                       ▼
Tap "Open sample details" ──▶ HomeMovieDetailsRoute(id: 101).push(context)
                                       │  generated location: /home/movie/101
                                       ▼
                 Home Navigator stack: [HomePage, MovieDetailsPage(movieId: 101)]
```

The full data flow (`View → Cubit/Bloc → UseCase → Repository → Fake API / drift`) arrives with real features in Phase 2+.

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `.fvmrc` | Pins Flutter 3.47.6 for this project. |
| `analysis_options.yaml` | Lints and strict analyzer modes; generated code excluded. |
| `lib/main.dart` | Bootstraps bindings, awaits DI, runs the app. |
| `lib/app/movie_explorer_app.dart` | Root widget: owns the router, applies the light/dark themes. |
| `lib/core/design_system/theme/app_theme.dart` | Material 3 themes from one seed color. |
| `lib/core/design_system/theme/app_colors.dart` | `ThemeExtension` with semantic app colors. |
| `lib/core/design_system/theme/app_{spacing,radius,icon_size}.dart` | Layout tokens. |
| `lib/core/design_system/widgets/{loading,error,empty_state}_view.dart` | Shared async-state widgets. |
| `lib/core/design_system/design_system.dart` | Barrel export for the design system. |
| `lib/core/navigation/app_routes.dart` (+ `.g.dart`) | Typed routes: the 4-branch shell and the per-tab Details routes. |
| `lib/core/navigation/app_router.dart` | `createAppRouter()`: redirect + not-found page. |
| `lib/core/navigation/app_shell.dart` | `NavigationBar` shell with re-tap-to-pop. |
| `lib/di/injection.dart` (+ `injection.config.dart`) | `get_it` + `injectable` composition root. |
| `lib/features/*/…_page.dart` | Placeholder screens (Home, Search, Favorites, Settings, Details). |
| `test/core/navigation/app_navigation_test.dart` | Tabs, per-tab stacks, back, re-tap-to-pop. |
| `test/core/design_system/**` | Theme, `AppColors` and state-widget tests. |
| `test/helpers/pump_app.dart` | `pumpThemed()` test helper. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `AppTheme` | `abstract final class` | Builds the light/dark `ThemeData` | `core/design_system`: pure UI concern |
| `AppColors` | `final class` (`ThemeExtension`) | Semantic colors beyond `ColorScheme` | `core/design_system`: travels inside the theme |
| `AppSpacing` / `AppRadius` / `AppIconSize` | `abstract final class` | Layout constants | `core/design_system` |
| `LoadingView` / `ErrorView` / `EmptyStateView` | `StatelessWidget` | Standard async-state UI | `core/design_system`: reused by every feature |
| `AppShellRoute` | `StatefulShellRouteData` | Declares the tab shell and its branches | `core/navigation`: the navigation contract |
| `HomeRoute`, `HomeMovieDetailsRoute`, … | `GoRouteData` (+ generated mixin) | One class per destination, with typed parameters | `core/navigation` |
| `AppShell` | `StatelessWidget` | `NavigationBar` + branch switching | `core/navigation`: it is navigation UI |
| `MovieExplorerApp` | `StatefulWidget` | Owns the router; wires the themes | `app/`: the root of the widget tree |
| `getIt` / `configureDependencies` | `GetIt` + function | Composition root | `di/`: the single place where implementations are chosen |

---

## 🌱 Folder Structure Changes

The entire top-level layout was introduced:
- `app/`;
- `core/{common,design_system,navigation,network,database,storage}`;
- `data/{mapper,repository}`;
- `domain/{model,repository,usecase}`;
- `features/{home,search,favorites,details,settings}`;
- `di/`.

The template counter app (`lib/main.dart` contents, `test/widget_test.dart`) was replaced, and `test/` now mirrors `lib/`.

---

## 🤖🍏 Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Pinned toolchain | Gradle wrapper + version catalog | Xcode version | FVM `.fvmrc` |
| Theme | `MaterialTheme` (`Theme.kt`, `Color.kt`) | `Color+Tokens.swift`, `Typography.swift` | `ThemeData` from `ColorScheme.fromSeed` + `AppColors` `ThemeExtension` |
| Layout tokens | `Spacing.kt` | `Theme.Spacing` / `CornerRadius` / `IconSize` | `AppSpacing` / `AppRadius` / `AppIconSize` |
| Shared state UI | placeholder composable | `LoadingView` / `ErrorView` / `EmptyStateView` | `LoadingView` / `ErrorView` / `EmptyStateView` |
| Routes | sealed `MovieExplorerRoute` with string patterns | `enum Route` | typed `GoRouteData` classes (generated) |
| Tabs | `NavigationBar` + `NavHost` (+ a drawer) | `TabView` + one `NavigationStack` per tab | `StatefulShellRoute` + `NavigationBar` |
| Per-tab back stack | `saveState` / `restoreState` | a `Router` per tab | a `Navigator` per branch |
| Composition root | Hilt (`@HiltAndroidApp` + modules) | `AppEnvironment` | `get_it` + `injectable` → `configureDependencies()` |
| UI tests | Compose UI tests | (none) | widget tests |

The biggest conceptual difference is navigation:
- **iOS:** the per-tab stacks are wired by hand: four `NavigationStack`s, each with its own `Router`.
- **Android:** Navigation Compose keeps one graph and saves/restores each tab's state.
- **Flutter:** `StatefulShellRoute` *declares* the branches, and go_router builds one Navigator per branch and keeps them alive.

---

## 🎤 Interview Notes

**Q: Why typed routes instead of `context.go('/home/movie/101')`?**
A: Each destination becomes a class with typed fields, and `go_router_builder` generates the path parsing and `location`. A wrong parameter type or a missing route is a compile error rather than a runtime 404, and refactors are safe.

**Q: How does `StatefulShellRoute` keep each tab's state?**
A: Each branch gets its own `Navigator`. The shell shows the branches in an `IndexedStack`, so inactive tabs stay mounted offstage, with `TickerMode` paused, and their stacks and scroll positions survive tab switches.

**Q: What is the difference between `go` and `push` in go_router?**
A: `go` navigates *declaratively* to a location and rebuilds the stack the route tree implies. `push` adds a page on top of the current stack and can return a result. For a details screen nested under the current tab, both end at `/home/movie/:id`. `push` matches the "open on top of this list" intent.

**Q: Why create the router inside `State` instead of as a top-level global?**
A: The router holds navigation state and must be disposed. Owning it in the root widget's `State` ties its lifetime to the app and gives each widget test a fresh router, so no state leaks between tests.

**Q: When would you use a `ThemeExtension` instead of `ColorScheme`?**
A: `ColorScheme` covers Material's roles (primary, surface, error…). App-specific semantics such as a "favorite" red or a rating-star amber belong in a `ThemeExtension`, which switches with light/dark mode and supports smooth `lerp` animations.

**Q: What changed about Material in Flutter 3.47?**
A: Material and Cupertino were decoupled from the SDK into the `material_ui` and `cupertino_ui` packages, which can now update independently. `dart fix --apply --code=migrate_design_widgets` migrates the imports. The in-SDK copies are scheduled for deprecation in the next stable release.

**Q: Service locator vs constructor injection: isn't `get_it` an anti-pattern?**
A: It is only a problem when classes pull dependencies from the locator themselves. Here every class receives its dependencies through its constructor; `get_it` is touched only at the edges (`main`, the router, Page widgets). `injectable` generates the wiring, much like Hilt does on Android.

**Q: Why FVM?**
A: Flutter versions change APIs and templates; 3.47 alone moved Material into a package. Pinning the version per project keeps builds reproducible, and lets older client projects stay on their own version on the same machine.

---

## 📝 Learning Checklist

- ✅ Pin a Flutter version per project with FVM
- ✅ Migrate to `material_ui` with `dart fix`
- ✅ Build Material 3 light/dark themes from a seed color
- ✅ Add app-specific tokens with a `ThemeExtension`
- ✅ Use Dart 3 class modifiers (`abstract final class`, `final class`)
- ✅ Declare typed routes and generate them with `build_runner`
- ✅ Give every tab its own back stack with `StatefulShellRoute`
- ✅ Set up a `get_it` + `injectable` composition root
- ✅ Write widget tests for navigation behaviour
- ⬜ Model results and errors with sealed classes (Phase 2)
- ⬜ Load bundled JSON through a fake API service (Phase 2)
- ⬜ Manage screen state with Cubit (Phase 2) and Bloc (Phase 4)
- ⬜ Persist and observe data with drift (Phase 3)
- ⬜ Persist settings with `SharedPreferencesWithCache` (Phase 4)

---

## 🚀 Future Improvements

- **Phase 2:** `Result` + `AppException`, `FakeMovieApiService` over the bundled JSON, `MovieRepository`, `HomeCubit` and the trending grid. It also removes the Home tab's temporary "Open sample details" button.
- **Phase 3:** replace the Details placeholder with the real screen, which receives its id through `@factoryParam`.
- **Adaptive layouts:** a `NavigationRail` on tablets/landscape would be a natural next step for the shell (out of scope for this learning project).
- **Localization:** `gen-l10n` instead of the label-only content language planned for Phase 4.
