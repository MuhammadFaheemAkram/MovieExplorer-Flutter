# Learning Notes

Every Flutter / Dart concept MovieExplorer uses, grouped by topic. Each one points to where it lives in the code. The phase write-ups ([1](PHASE_1_SUMMARY.md) · [2](PHASE_2_SUMMARY.md) · [3](PHASE_3_SUMMARY.md) · [4](PHASE_4_SUMMARY.md)) explain the *why* in more depth.

---

## 1. Toolchain and project setup

| Concept | Where | Notes |
|---|---|---|
| FVM per-project pinning | `.fvmrc` | The Flutter version is part of the repo, like the Gradle wrapper. Run everything as `fvm flutter …`. |
| `material_ui` package | every UI file | In Flutter 3.47, Material left the core SDK. `dart fix --apply --code=migrate_design_widgets` rewrites the imports. |
| Strict analysis | `analysis_options.yaml` | `strict-casts`, `strict-inference`, `strict-raw-types`. Generated files stay **in scope**, so their compile errors are reported (lints are silenced with headers). |
| Code generation | `build.yaml`, `*.g.dart`, `*.freezed.dart`, `*.config.dart` | `build_runner` turns annotations into committed `part` files; CI fails if they are stale. |
| Builder options | `build.yaml` | drift's `store_date_time_values_as_text`; source_gen's `ignore_for_file: [type=lint]` header. |

## 2. Dart language

- **Sealed classes + exhaustive `switch`** (`AppException`, `Result`, every UI state). A missing case is a compile error.
- **Class modifiers:** `final class` (closed value types such as `AppColors`), `abstract final class` (constant namespaces such as `AppSpacing`, `HeroTags`).
- **Primary constructors (Dart 3.13):** `final class const Ok<T>(final T value) extends Result<T>;`.
- **Generic covariance:** `const Err(UnknownException())` infers `Err<Never>`, which is still a `Result<T>`.
- **Patterns**
  - destructuring `case Ok(:final value)`;
  - the null-check pattern `Ok(value: final row?)`;
  - guards `case Err() when !hasContent`;
  - `if (state case MovieDetailsLoaded(:final movie))`;
  - logical-or patterns `SearchResults() || SearchNoResults() => true`.
- **Records + destructuring:** `final (hi, lo) = (a.computeLuminance(), b.computeLuminance());` (the contrast test).
- **Enhanced enums** with fields and getters (`ContentLanguage('Deutsch')`, `code`), plus `values.asNameMap()` for safe parsing.
- **Extensions:** `BuildContext.appColors`, `AppThemeMode.toThemeMode()`, the favorite overlay on `Movie` / `List<Movie>`, `WidgetTester` test helpers.
- **Collection `if` / `for`** inside widget lists.
- **Constructor tear-offs:** `objects.map(MovieDto.fromJson)`.

## 3. Architecture

- **Layers:** `domain/` (pure Dart) ← `data/` (implementations) ← `core/` (infrastructure) ← `features/` (UI). See [ARCHITECTURE.md](ARCHITECTURE.md).
- **Repository pattern:** contracts in `domain/repository`, implementations in `data/repository`, chosen by DI.
- **Use cases:** one small callable class per operation (`call()`), so Cubits depend on intent, not on repositories.
- **`Result<T>` instead of exceptions** across the data → domain boundary. Data sources throw `AppException`s; repositories convert them.
- **Mappers** live next to the data they map: the DTO mapper and the drift-row mapper are separate files, keeping the JSON and drift imports apart.
- **Single source of truth:** drift for favorites, `SettingsRepositoryImpl` for settings. Screens overlay derived state; they never keep their own copy.
- **Page / View split:** the Page wires DI and navigation; the View renders state and exposes callbacks, so it can be tested without a router or `getIt`.

## 4. State management (flutter_bloc)

| Concept | Where |
|---|---|
| Cubit with `emit` and an initial state | `HomeCubit`, `FavoritesCubit`, `MovieDetailsCubit`, `SettingsCubit` |
| Bloc with events (`on<E>`) | `SearchBloc` |
| freezed sealed states, rendered with an exhaustive `switch` | every `*_state.dart` |
| `isClosed` guard after `await` | every Cubit with async work |
| Stream subscriptions: subscribe in the constructor, cancel in `close()` | Home, Favorites, Details, Settings |
| Emitting only on a real change (Bloc's first-emit exception) | Home / Details overlays, `SettingsCubit` |
| Optimistic update + rollback | `FavoritesCubit.remove` |
| One-time effects with `BlocConsumer` / `listenWhen` | the Home refresh SnackBar |
| `BlocProvider(create:)` owns and closes the Cubit | every Page |
| App-scoped Cubit above `MaterialApp.router` | `MovieExplorerApp` + `SettingsCubit` |
| Rebuilding only on a slice of state | `BlocSelector<SettingsCubit, AppSettings, AppThemeMode>`, `context.select(...)` |
| **Event transformers** | `search_transformers.dart`, `search_bloc.dart` |

**Event transformers in detail.** A transformer decides how a Bloc processes a stream of events:
- **`restartable()`** cancels the running handler when a new event arrives (latest wins);
- **`droppable()`** ignores new events while one is running;
- **`sequential()`** queues them; **`concurrent()`** (the default) runs them all at once.

`debounceRestartable` composes `stream_transform`'s `switchMap` (each new keystroke restarts a timer) with `restartable()` (each new search cancels the old one). Blank queries bypass the timer, so clearing the field is instant.

## 5. Dependency injection (get_it + injectable)

- `@InjectableInit` generates `getIt.init()`; `main()` awaits `configureDependencies()` before `runApp`.
- **Scopes:** `@injectable` (a new instance each time) for use cases and Cubits; `@lazySingleton` for infrastructure.
- **Interface binding:** `@LazySingleton(as: MovieRepository)`.
- **`@module`** registers types you don't own (`AssetBundle`, `AppDatabase`, `SharedPreferencesWithCache`, `PackageInfo`).
- **`@preResolve`:** async factories awaited during `init()`, so the rest of the app reads them synchronously.
- **`@factoryParam`:** runtime arguments (`movieId`, `preview`) passed as `getIt<MovieDetailsCubit>(param1:, param2:)`.
- **`@ignoreParam`:** a constructor parameter DI leaves alone (Search's debounce, which tests shorten).
- **Gotcha:** `@disposeMethod` on an `as:` registration generates a call on the *interface*. Dispose those from code instead.
- **Tests** register fakes with the same `getIt` and `getIt.reset()` in `tearDown`.

## 6. Navigation (go_router + go_router_builder)

- `MaterialApp.router(routerConfig:)`, top-level `redirect` (`/` → `/home`), and an `errorBuilder`.
- **Typed routes:** `@TypedGoRoute`, `@TypedStatefulShellRoute`, and `GoRouteData` classes with generated `go()` / `push()` / `location`. `int` path parameters are parsed for you.
- **`StatefulShellRoute.indexedStack`:** one `Navigator` per tab, kept alive offstage; `goBranch(index, initialLocation:)` re-taps to pop to root.
- **Per-tab child routes:** `/home/movie/:id`, `/search/movie/:id` and `/favorites/movie/:id` push Details inside the current tab.
- **Typed `$extra`:** a `Movie?` preview travels with the push, so `Hero` has a target and Details renders at once. Deep links have no extra.
- The router is created in `State` and disposed with it, not kept in a global.

## 7. UI and Material 3

- **Theming:** `ColorScheme.fromSeed` (`#4D5CE6`), component themes, `ThemeMode` (system / light / dark) driven by state.
- **`ThemeExtension`** (`AppColors`): semantic colors such as `favorite` / `onFavorite`, with `copyWith` and `lerp` so theme changes animate.
- **Design tokens:** `AppSpacing`, `AppRadius` and `AppIconSize` constants instead of magic numbers.
- **Widgets used:**
  - layout and lists: `GridView.builder`, `ListView`, `CustomScrollView` + `SliverAppBar` + `FlexibleSpaceBar` + `SliverList`;
  - controls: `NavigationBar`, `SearchBar`, `SegmentedButton`, `DropdownMenu`, `FilledButton.icon` / `.tonalIcon`, `Chip`;
  - feedback and info: `RefreshIndicator`, `Dismissible`, `SnackBar`, `AboutListTile` (with the generated licenses page);
  - images and transitions: `Hero`, `CachedNetworkImage`.
- **`SystemUiOverlayStyle`:** light status-bar icons over the Details backdrop. A `ScrollController` switches them back once the header collapses.
- **Contrast:** text on custom fills uses a paired `on…` color checked against WCAG AA (4.5:1). A unit test enforces it.
- **Accessibility:**
  - `Semantics` labels on cards and badges, and `Semantics(header: true)` on section titles;
  - tooltips that double as screen-reader labels;
  - large-text overflow tests.

## 8. Data and persistence

- **JSON:** `json_serializable` with `fieldRename: snake`, `checked: true` (a malformed catalog becomes a `DataFormatException`) and `createToJson: false`.
- **freezed 4:** `@freezed abstract class` data classes, `sealed class` unions, `@Default`, `copyWith`, deep equality.
- **Assets:** declared in `pubspec.yaml`, read through an injected `AssetBundle`.
- **drift**
  - **Schema:** the table DSL, `@DataClassName`, a JSON `TypeConverter`, and UTC ISO-8601 `DateTime`s.
  - **DAO:** `select` / `selectOnly` / `where` / `orderBy`.
  - **Reactive queries:** `watch()` streams re-run whenever a table they read changes.
  - **Writes:** `transaction` for the read-decide-write toggle. There is one database instance per app, so change notifications reach every watcher.
- **`SharedPreferencesWithCache`**
  - Created asynchronously once, with an `allowList`; after that, reads are synchronous.
  - Writes update the cache immediately and reach the disk asynchronously.
  - Enum values are stored by `name` and parsed defensively.
- **Broadcast streams:** `SettingsRepositoryImpl` uses a `StreamController.broadcast(sync: true)` for changes. `watchSettings()` uses an `onListen` controller to emit the current value first, like drift's `watch()`.

## 9. Testing

- **Unit tests** for mappers, use cases, the fake API (against the **real** bundled JSON), repositories and drift (`NativeDatabase.memory()`).
- **`bloc_test`:** `blocTest` with `build` / `seed` / `act` / `wait` / `expect` / `verify`; short debounces through `@ignoreParam`.
- **Fakes over mocks** for data (`FakeMovieRepository`, `FakeSettingsRepository`), with a `Completer` gate to hold a request in flight.
- **Widget tests:** `MockCubit` / `MockBloc` + `whenListen`, a phone-sized surface, semantics finders, and large-text overflow checks.
- **App-level tests** pump the real app with fakes registered in `getIt`: tabs, back stacks, Search end to end, theme switching, saved settings on the first frame.
- **`InMemorySharedPreferencesAsync`** runs the real `SharedPreferencesWithCache` code in tests.
- **Bounded waits:** `StreamQueue` + timeout, so a broken stream fails instead of hanging.
- **Regression tests** for bugs found during development: restartable + dedupe getting stuck on loading, and the dark-theme button contrast.

## 10. Tooling and repo hygiene

- **CI** (`.github/workflows/flutter-ci.yml`):
  - `kuhnroyal/flutter-fvm-config-action` installs the version from `.fvmrc`;
  - `build_runner` + `git diff --exit-code` checks that generated code is fresh;
  - then format, analyze and test.
- **Conventional Commits:** one commit per phase.
- **Open-source files:** LICENSE (MIT), CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, CHANGELOG (Keep a Changelog), issue and PR templates.
