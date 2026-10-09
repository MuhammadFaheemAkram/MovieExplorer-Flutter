# Phase 4 — Search + Settings + Tests + Polish

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 4, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions solved the same problems.

---

## 🎯 Phase Goal

Phase 4 completes the app and makes it a finished open-source project:

- **Search** by title or genre. Typing is debounced, and an older search can never overwrite a newer one. This is the one place where an **event-driven Bloc** with **event transformers** earns its keep over a Cubit.
- **Settings**: appearance (System / Light / Dark) and content language. Both are persisted and applied **app-wide**, and the saved theme is applied on the very first frame.
- **Polish**: a dark-mode check on every screen, a readable status bar over the Details backdrop, a contrast fix, and copy and semantics for the remaining states.
- **Repo**: CI, the community files, and the final docs (architecture, testing, learning notes, interview notes, roadmap, screenshots).

It completes the architecture with a second persistence mechanism (key-value preferences next to drift) and the first **app-scoped** state holder.

---

## 🧱 What Was Implemented

- **Packages:** `bloc_concurrency`, `stream_transform`, `shared_preferences` and `package_info_plus`; dev: `shared_preferences_platform_interface` (an in-memory store for tests).
- **Search**
  - `SearchEvent`: `SearchQueryChanged(query)` and `SearchRetried()`.
  - `SearchState` (freezed): `idle`, `loading`, `results`, `noResults(query)` and `error(message)`.
  - **`debounceRestartable(duration)`**: `switchMap` + `Future.delayed` debounces non-blank queries (blank ones pass at once), then `restartable()` cancels the in-flight handler.
  - `SearchBloc`:
    - query changes use `debounceRestartable(300 ms)`; retries use `droppable()`;
    - it tracks the last query, so the query already on screen isn't searched twice, while a *cancelled* one is searched again;
    - the debounce is an `@ignoreParam` constructor argument, so tests can shorten it.
  - `SearchView`: a Material 3 `SearchBar` ("Title or genre") with a clear button, and every state rendered with an exhaustive `switch`. Results reuse `MovieRow` with Hero tags.
  - `SearchPage` pushes `SearchMovieDetailsRoute(id:, $extra: movie)`. The temporary sample button is gone.
- **Settings**
  - Domain:
    - `AppThemeMode` (system / light / dark);
    - `ContentLanguage` (en / es / de / ar / ur, each named in its own script);
    - freezed `AppSettings`;
    - the `SettingsRepository` contract;
    - four use cases (get, watch, update theme mode, update language).
  - Storage:
    - `SharedPreferencesWithCache` is created in `AppModule` as a **`@preResolve`** singleton, with an allow-list of the two keys;
    - `SettingsLocalDataSource` owns the keys.
  - `SettingsRepositoryImpl`:
    - keeps the current value and publishes changes on a synchronous broadcast stream;
    - `watchSettings()` emits the current value on listen;
    - it stores enums by name and falls back to defaults for unknown values.
  - `SettingsCubit` (**app-scoped**):
    - its initial state is read synchronously;
    - it mirrors the repository stream, and its intents call the update use cases.
  - `MovieExplorerApp` provides the Cubit above `MaterialApp.router`. A `BlocSelector` feeds `themeMode`; `AppThemeMode.toThemeMode()` maps it.
  - `SettingsView`:
    - an Appearance `SegmentedButton`;
    - a Content language `DropdownMenu` with helper text ("Shown as a label on Home; no translations yet.");
    - About: the app name, the version from `package_info_plus` and a description, plus `AboutListTile` for the generated licenses page;
    - section headers marked `Semantics(header: true)`.
  - Home shows the content-language **badge** (`EN`, `DE`, …) in its app bar, read with `context.select`.
- **Polish**
  - **Details status bar:**
    - light icons over the backdrop, using `systemOverlayStyle`;
    - a soft black-to-clear gradient at the top;
    - a `ScrollController` returns to the theme default once the header collapses.
  - **Contrast:** `AppColors` gains `onFavorite`. In dark mode, the "In favorites" button had white text on the lighter red (about 2.8:1, below WCAG AA). It now uses a deep red-black (about 6.2:1). A unit test checks both themes.
  - Every screen was checked in light and dark mode on the iOS simulator.
- **Analysis:** generated files are **no longer excluded** (see "Bugs found along the way"). Their lints are silenced by a `// ignore_for_file: type=lint` header, written by source_gen through `build.yaml`.
- **Tests:** 38 new, **159 in total**.
- **Repo**
  - `.github/workflows/flutter-ci.yml`;
  - issue and PR templates;
  - LICENSE (MIT), CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, CHANGELOG.
- **Docs**
  - new: ARCHITECTURE, TESTING, LEARNING_NOTES, INTERVIEW_NOTES, ROADMAP, SCREENSHOTS (with six screenshots), and this summary;
  - the final README;
  - two new verified traps in `00-CONVENTIONS.md` §11.15–11.16.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **Bloc events and event transformers**
  - `on<E>(handler, transformer: ...)`.
  - `bloc_concurrency`: `restartable`, `droppable`, `sequential`, `concurrent`.
  - Composing a custom `EventTransformer` from `stream_transform`'s `switchMap`.
  - What *cancelling a handler* means: the `Emitter` is closed, so the old handler's later `emit`s are ignored.
- **Choosing Cubit vs Bloc:** Search is the only screen whose input is a *stream of intents* that needs shaping.
- **App-scoped state:**
  - a `BlocProvider` above `MaterialApp.router`;
  - `BlocSelector` to rebuild only on `themeMode`;
  - `context.select` for one field elsewhere.
- **`ThemeMode`-driven theming:** `MaterialApp.themeMode` with the `theme` / `darkTheme` pair; mapping a domain enum to a Flutter type in the `app/` layer, so the domain stays Flutter-free.
- **`shared_preferences`**
  - The three APIs: legacy, `SharedPreferencesAsync` and `SharedPreferencesWithCache`. The cache variant uses an `allowList`.
  - Synchronous reads after one async init.
  - `InMemorySharedPreferencesAsync` for tests.
- **injectable `@preResolve`:** async singletons awaited inside `configureDependencies()`.
- **Streams:**
  - `StreamController.broadcast(sync: true)`;
  - an `onListen` controller that emits the current value first, then forwards changes (a "behavior subject" without RxDart).
- **Enhanced enums:** fields, getters and `values.asNameMap()` for defensive parsing.
- **Material 3 widgets:** `SearchBar`, `SegmentedButton`, `DropdownMenu`, `AboutListTile` (the licenses page comes for free).
- **System UI:** `SystemUiOverlayStyle` through `SliverAppBar.systemOverlayStyle`, toggled from scroll position.
- **Contrast:** WCAG relative luminance (`Color.computeLuminance()`) and the 4.5:1 rule, enforced by a test.
- **`package_info_plus`:** the version and build number from the platform bundle, faked in tests.
- **CI:** GitHub Actions with the FVM-pinned Flutter, checking generated code with `git diff --exit-code`.

---

## 🔁 Data Flow (this phase)

```
Search
keystroke ─▶ SearchBar.onChanged ─▶ SearchQueryChanged(q)
  └─▶ debounceRestartable(300 ms)
        blank? ─────────────────▶ handler: idle (pending search dropped)
        else ─ wait 300 ms (a newer keystroke restarts the wait)
             └─▶ restartable: cancel the in-flight handler ─▶ _onQueryChanged
                   already shown? ─▶ skip
                   else ─▶ loading ─▶ SearchMoviesUseCase ─▶ MovieRepository ─▶ FakeMovieApiService
                                       └─▶ Ok([])   → noResults(q)
                                           Ok(list) → results(list)
                                           Err(e)   → error(e.message) ──▶ Retry ─▶ SearchRetried (droppable)

Settings
main() ─▶ configureDependencies() ─▶ await SharedPreferencesWithCache.create (@preResolve)
runApp ─▶ BlocProvider(SettingsCubit: initial state read synchronously) ─▶ BlocSelector ─▶ MaterialApp.router(themeMode)

SegmentedButton / DropdownMenu ─▶ SettingsCubit.selectThemeMode / selectLanguage
  └─▶ Update…UseCase ─▶ SettingsRepositoryImpl ─▶ prefs (cache now, disk async) + _changes stream
        └─▶ watchSettings() ─▶ SettingsCubit.emit ─▶ MaterialApp restyles · Home badge updates
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `lib/features/search/bloc/search_event.dart` | The Search intents. |
| `lib/features/search/bloc/search_state.dart` (+ `.freezed.dart`) | The Search states. |
| `lib/features/search/bloc/search_transformers.dart` | `debounceRestartable`: debounce + cancel. |
| `lib/features/search/bloc/search_bloc.dart` | The Search logic, last-query tracking and retry. |
| `lib/features/search/search_view.dart` | `SearchBar` + every state. |
| `lib/domain/model/{app_theme_mode,content_language,app_settings}.dart` | The settings domain. |
| `lib/domain/repository/settings_repository.dart` | The settings contract. |
| `lib/domain/usecase/{get_settings,watch_settings,update_theme_mode,update_language}_use_case.dart` | Settings use cases. |
| `lib/core/storage/settings_local_data_source.dart` | The preference keys + the `SharedPreferencesWithCache` wrapper. |
| `lib/data/repository/settings_repository_impl.dart` | Current value + change stream. |
| `lib/features/settings/cubit/settings_cubit.dart` | App-scoped settings state. |
| `lib/features/settings/settings_view.dart` | The Appearance, Content language and About sections. |
| `lib/app/theme_mode_mapper.dart` | `AppThemeMode` → `ThemeMode`. |
| `test/helpers/fakes/fake_settings_repository.dart` | An in-memory settings fake. |
| `.github/workflows/flutter-ci.yml` | CI. |
| `docs/*.md`, `docs/screenshots/*.png`, community files | The open-source package. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `SearchEvent` / `SearchQueryChanged` / `SearchRetried` | sealed class + subclasses | Search intents | `features/search/bloc`: presentation only |
| `SearchState` | freezed sealed union | idle / loading / results / noResults / error | `features/search/bloc` |
| `debounceRestartable` | `EventTransformer` factory | Debounce + cancellation | next to the Bloc that uses it |
| `SearchBloc` | Bloc | Search orchestration | `features/search/bloc` |
| `AppThemeMode`, `ContentLanguage` | enhanced enums | Settings values, free of Flutter types | `domain/model`: pure Dart |
| `AppSettings` | freezed data class | The settings snapshot | `domain/model` |
| `SettingsRepository` | abstract interface | read / watch / update | `domain/repository` |
| `SettingsLocalDataSource` | class | The keys + raw string reads and writes | `core/storage`: infrastructure |
| `SettingsRepositoryImpl` | class | Parse, default, publish | `data/repository` |
| `SettingsCubit` | Cubit | App-wide settings state | `features/settings/cubit`, provided by `app/` |
| `AppThemeModeX` | extension | Domain → Flutter `ThemeMode` | `app/`: the only layer that knows both |

---

## 🌱 Folder Structure Changes

- **New:**
  - `lib/features/search/bloc/` and `lib/features/settings/cubit/`;
  - the first real file in `lib/core/storage/` (its `.gitkeep` is gone);
  - `lib/app/theme_mode_mapper.dart`;
  - `.github/` and `docs/screenshots/`.
- **Tests:** `test/features/search/`, `test/features/settings/`, `test/data/repository/settings_repository_impl_test.dart` and `test/domain/model/settings_models_test.dart`.
- **Config:**
  - `analysis_options.yaml` now excludes only `build/`, `android/` and `ios/`;
  - `build.yaml` adds the source_gen lint header option.

---

## 🤖🍏 Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Search input | `uiState.map { query }` | Combine `PassthroughSubject` | `SearchQueryChanged` events |
| Debounce | Flow `debounce(350)` | Combine `debounce(300 ms)` | `switchMap` + `Future.delayed(300 ms)` |
| Duplicates | `distinctUntilChanged()` | `removeDuplicates()` | skip only if that query's result is **shown** |
| Stale results | `collectLatest` cancels the previous search | each query starts a new `Task`; the older one isn't cancelled | `restartable()` cancels the previous handler |
| Retry | `viewModelScope.launch { search() }` | n/a | `SearchRetried` + `droppable()` |
| Settings store | DataStore (Preferences) | `UserDefaults` in a `SettingsStore` | `SharedPreferencesWithCache` |
| Settings stream | DataStore `Flow` | an `AsyncStream` of continuations | a broadcast stream + `onListen` current value |
| Theme setting | boolean `darkModeEnabled` | `AppTheme` system/light/dark | `AppThemeMode` system/light/dark |
| Applying the theme | `MovieExplorerTheme(darkTheme = …)` in `MainActivity` | `.preferredColorScheme(...)` on the root view | `MaterialApp.themeMode` from an app-scoped Cubit |
| Languages | en, es, ur | en, es, de, ar | the union: en, es, de, ar, ur |
| About / version | a static About screen (no version) | `Bundle.main` `CFBundleShortVersionString` | `package_info_plus` + `AboutListTile` |

**Divergences:**
- Flutter follows iOS on the three-way theme choice. "System" is the better default, and Android's boolean can't express it.
- It takes the union of both language lists.
- It adds explicit cancellation, which the iOS Combine pipeline lacks (an older `Task` can finish after a newer one).

---

## 🐞 Bugs found along the way

1. **Search stuck on loading.**
   - **Bug:** the first dedupe skipped any query equal to the last one. When the in-flight query was re-typed (`harbor` in flight → `harbo` → `harbor`), `restartable` cancelled its handler, and the new event was skipped as "unchanged".
   - **Fix:** skip only when `results` / `noResults` for that query are on screen. Covered by a regression `blocTest`.
2. **A generated-code compile error the analyzer didn't report.**
   - **Bug:** `@disposeMethod` on `SettingsRepositoryImpl` (registered `as: SettingsRepository`) generated `i.dispose()` on the interface. `flutter analyze` stayed green because `*.config.dart` was excluded; only the test compile failed.
   - **Fix:** keep generated files in scope and silence only their lints, with a header written by source_gen through `build.yaml`. `@disposeMethod` is gone too.
3. **Low contrast in dark mode.** White on `#FF6B6B` is about 2.8:1. Found during the dark-mode pass on the simulator; fixed with the `onFavorite` token and guarded by a test.

---

## 🎤 Interview Notes

**Q: Why is Search a Bloc when every other screen is a Cubit?**
A: Its input is a *stream* of keystrokes that needs shaping (debounce, cancel stale work, ignore duplicate retries). Bloc event transformers express that declaratively. A Cubit would need hand-written timers and cancellation tokens.

**Q: What's the difference between `restartable`, `droppable`, `sequential` and `concurrent`?**
A: For events arriving while a handler is running:
- `restartable` cancels the old handler (latest wins: search);
- `droppable` ignores the new event (first wins: retry or submit buttons);
- `sequential` queues it (ordered writes);
- `concurrent`, the default, runs both.

**Q: Isn't debounce enough on its own?**
A: No. Debounce limits how many searches start, not the order in which they finish. With 400 ms of latency, a search started before a pause can still be in flight when the next one starts, and its late result would overwrite the newer one. Cancellation fixes ordering.

**Q: How does the app avoid a light flash when the saved theme is Dark?**
A: Preferences are loaded before `runApp` (`@preResolve`), and the Cubit's initial state is read synchronously from the cache. The first frame is already dark.

**Q: Why isn't `SettingsCubit` created in the Settings page?**
A: The theme mode is an input to `MaterialApp`, and Home shows the language. State that several screens and the app root depend on belongs above them. Also, shell branches are built lazily: a Cubit created by the Settings page wouldn't exist until that tab was first opened, so a saved theme wouldn't apply at launch.

**Q: How do you test `SharedPreferencesWithCache`?**
A: Set `SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty()`, then create the real cache. Tests run the real code against an in-memory store, which is better than mocking the plugin.

**Q: What would you change for a real app?**
A:
- Localize the UI with `gen-l10n` (and support right-to-left layout for Arabic and Urdu), so the language setting actually translates.
- Send the language to the API.
- Add integration tests on devices.

---

## 📝 Learning Checklist

- ✅ Write a Bloc with events and choose event transformers deliberately
- ✅ Compose a custom `EventTransformer` (debounce + restartable)
- ✅ Test debounced, cancellable flows with `blocTest` and a gated fake
- ✅ Persist settings with `SharedPreferencesWithCache` and read them synchronously
- ✅ Resolve async dependencies before `runApp` with `@preResolve`
- ✅ Drive the app-wide theme from an app-scoped Cubit (`BlocSelector`, `context.select`)
- ✅ Use the Material 3 `SearchBar`, `SegmentedButton`, `DropdownMenu` and `AboutListTile`
- ✅ Control the status bar style per screen (`SystemUiOverlayStyle`)
- ✅ Check color contrast against WCAG AA, and enforce it in a test
- ✅ Set up CI that verifies codegen, formatting, analysis and tests
- ✅ Ship the open-source package: license, contributing, conduct, security, changelog, templates

---

## 🚀 Future Improvements

See [ROADMAP.md](ROADMAP.md). The most valuable next steps:
- **Real localization:** `gen-l10n` + ARB files, with right-to-left layout for العربية and اردو. The language setting is only a label today.
- **A real TMDB client** behind `MovieApiService`, with the key injected at build time.
- **Offline Home:** trending cached in drift (stale-while-revalidate).
- **`integration_test`** flows on devices, plus golden tests for the design system.
- **Adaptive layout:** `NavigationRail` and list–detail on tablets.
