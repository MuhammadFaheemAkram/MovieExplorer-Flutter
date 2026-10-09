# Interview Notes

Questions you could be asked about this app, with short answers grounded in its code. Use them to rehearse explaining a real Flutter codebase end to end.

---

## Architecture

**Q: Walk me through the architecture.**
A: Three layers plus infrastructure:
- **domain/** is pure Dart: entities, repository contracts, use cases.
- **data/** implements the contracts and maps data.
- **core/** holds infrastructure: the fake API, drift, preferences, design system, navigation.
- **features/** has a Page, a View and a Cubit/Bloc per screen.

Dependencies point inwards, so the domain knows nothing about Flutter, drift or JSON. Widgets send intents to the Cubit; the Cubit calls use cases, and immutable state flows back.

**Q: Why use cases, when they mostly just call the repository?**
A: They name the operations the app supports (`SearchMoviesUseCase`, `ToggleFavoriteUseCase`), keep Cubits independent of repository shape, and give business rules a home when they appear. They are tiny `call()` classes, so the cost is low. On a smaller app I'd happily skip them.

**Q: Why return `Result<T>` instead of throwing?**
A: Failure becomes part of the type. A sealed `Result` (`Ok` / `Err`) consumed with an exhaustive `switch` can't be ignored by accident, and nothing above the data layer needs `try`/`catch`. Data sources still throw typed `AppException`s; the repository is the one place that converts them.

**Q: Where does the "single source of truth" live?**
A: Favorites live in drift. Every heart overlays `isFavorite` from one `watchFavoriteIds()` stream, so screens can't disagree. Settings live in `SettingsRepositoryImpl`, which publishes changes; the app-scoped `SettingsCubit` mirrors it.

**Q: Why a Page / View split?**
A: The Page wires DI and navigation (`getIt`, typed routes). The View only renders state and exposes callbacks, so widget tests drive it with a mocked Cubit and no router or service locator.

## State management

**Q: Cubit or Bloc: how do you choose?**
A: Cubit by default: Home, Favorites, Details and Settings have plain intents. Search is a Bloc because its events need **transformers**: debounce, cancellation of stale searches, and dropping duplicate retries. With a Cubit, I'd be hand-rolling timers and cancellation tokens.

**Q: How is search debounced, and why `restartable`?**
A: `debounceRestartable` combines two steps:
- `switchMap` delays each query by 300 ms and restarts the timer on every keystroke;
- `restartable()` then cancels the in-flight handler when a newer query arrives.

Debounce alone cuts the number of requests, but a slow, older response could still land after a newer one and overwrite it. `restartable` makes the latest query win. Blank queries skip the delay, so clearing the field is instant.

**Q: Tell me about a bug you found.**
A: Search skipped a query if it equalled the last one, to avoid re-searching what's on screen. Then a user deletes and re-types a character while the search is in flight. The re-typed query cancels the original handler (`restartable`), but the dedupe sees an "unchanged" query and returns, so the screen is stuck on loading. The fix only skips when results for that query are already *shown*. A `blocTest` regression covers it.

**Q: Why do some Cubits compare states before emitting, if Bloc already drops duplicates?**
A: Bloc drops a state equal to the current one *except on the very first emit*. Details starts with a preview state, so its first favorite overlay would re-emit an identical state. An explicit `if (updated != current)` states the intent and avoids that rebuild.

**Q: How do you manage stream subscriptions in a Cubit?**
A: Subscribe in the constructor, keep the `StreamSubscription`, and cancel it in an overridden `close()` before `super.close()`. After every `await`, check `isClosed` before emitting.

**Q: Why is `SettingsCubit` above `MaterialApp.router`?**
A: The theme mode is an input to `MaterialApp`, so the Cubit must exist above it. A `BlocSelector` rebuilds `MaterialApp` only when `themeMode` changes, not when the language does. Home reads the language with `context.select`.

**Q: What is an optimistic update, and where do you use one?**
A: In Favorites removal. The row leaves the state immediately, the write follows, and a failure rolls back. It's required here: a dismissed `Dismissible` throws if the list rebuilds with it still present, and drift's confirmation arrives a moment later.

## Dependency injection

**Q: Why `get_it` + `injectable` instead of Provider or Riverpod for DI?**
A: Explicit, generated constructor injection, much like Hilt/Dagger. Annotations declare scope and binding, codegen writes the wiring, and tests swap fakes into the same container. Bloc handles state, so DI only needs to construct objects.

**Q: How does the saved theme apply on the first frame?**
A: `SharedPreferencesWithCache.create(...)` is an `@preResolve` module member, so `configureDependencies()` awaits it before `runApp`. After that, preference reads are synchronous. `SettingsCubit`'s initial state comes from `GetSettingsUseCase` synchronously, so the first frame is already dark: no flash, no loading state.

**Q: How do runtime arguments reach a DI-built Cubit?**
A: `@factoryParam`: `getIt<MovieDetailsCubit>(param1: id, param2: preview)`. Everything else is still injected.

**Q: Did the codegen ever bite you?**
A: Yes. `@disposeMethod` on a class registered `as: SettingsRepository` generated `dispose: (i) => i.dispose()` against the *interface*, which has no `dispose`. `flutter analyze` didn't report it because generated files were excluded from analysis; the test compile did. The fix was to stop excluding generated files and silence only their lints, through a header that `build.yaml` adds.

## Navigation

**Q: How does each tab keep its own back stack?**
A: `StatefulShellRoute.indexedStack` gives every branch its own `Navigator`, kept alive offstage. Re-tapping the active tab calls `goBranch(index, initialLocation: true)` to pop to its root.

**Q: Why is Details a child route of every list tab?**
A: So it pushes inside the current tab (`/search/movie/7`), keeping the bottom bar and the tab's history. One shared top-level route would jump out of the tab.

**Q: What's the `$extra` preview for?**
A: The list already has the movie, so it passes it as a typed `$extra`. Details renders at once, which gives the `Hero` a destination, then refreshes quietly. A deep link has no extra and starts in the loading state.

## Persistence

**Q: Why drift for favorites and `shared_preferences` for settings?**
A: Favorites are relational data that must be queried and **observed**. drift gives typed SQL, `watch()` streams and transactions. Settings are two scalar values; a key-value store is the right size.

**Q: How does drift know when to re-run a `watch()` query?**
A: It tracks which tables each query reads. Any write through the same database instance to those tables re-runs the query. That's why the app has exactly one `AppDatabase`.

**Q: Why `SharedPreferencesWithCache` and not `SharedPreferencesAsync`?**
A: The async API makes every read a `Future`, which would force a loading state or a theme flash at startup. The cache variant loads the allow-listed keys once and reads synchronously after that.

**Q: How do you store enums safely?**
A: By `name` (`dark`, `de`), parsed back with `values.asNameMap()[raw] ?? default`. A renamed or unknown value falls back instead of crashing.

## UI and accessibility

**Q: How do you handle colors Material's `ColorScheme` doesn't cover?**
A: With the `AppColors` `ThemeExtension`: `favorite`, `onFavorite`, `ratingStar`, `badgeScrim`. It switches with the theme, animates via `lerp`, and widgets ask for an intent instead of a hex value.

**Q: Any accessibility issue you caught?**
A: In dark mode, the "In favorites" button drew white text on the lighter dark-theme red, about 2.8:1, well below WCAG AA's 4.5:1. I added an `onFavorite` token (deep red-black in dark mode, about 6:1) and a unit test that computes the contrast for both themes.

**Q: How does the Details screen keep the status bar readable?**
A: Over the photo backdrop, `SliverAppBar.systemOverlayStyle` uses light icons, with a soft top gradient. A `ScrollController` switches back to the theme default once the header collapses under the toolbar.

## Testing

**Q: How is the app tested?**
A: 159 tests:
- unit tests for mappers, use cases, the fake API (against the real JSON), repositories and drift (in-memory SQLite);
- `blocTest` for every Cubit and the Bloc;
- widget tests for every View with `MockCubit` / `MockBloc` on a phone-sized surface;
- app-level tests that pump the real app with fakes registered in `getIt`.

CI regenerates code, then runs format, analyze and test.

**Q: Fakes or mocks?**
A: Fakes for data: `FakeMovieRepository` behaves like the real thing, including drift-style streams and a `Completer` gate that holds a request in flight. Mocks only where the test is about the UI (`MockCubit` + `whenListen`).

**Q: How do you test a debounced, cancellable Bloc without slow tests?**
A: The debounce duration is an `@ignoreParam` constructor parameter, so tests pass a few milliseconds and app tests pass zero. A gate in the fake keeps a search in flight while the test sends a newer query, proving the old result never shows.

**Q: Any flaky-test traps?**
A: A few:
- unbounded waits: every `StreamQueue.next` has a timeout;
- `pumpAndSettle` never settles while a spinner animates;
- writing to drift before the first `watch()` value arrives means you only ever see the after-write state.

## Cross-platform comparison

**Q: How would this look natively?**
A:
- **Android:** a Hilt ViewModel per screen; `StateFlow` + `debounce` + `collectLatest` for search; Room with `Flow` for favorites; DataStore for settings.
- **iOS:** `@Observable` view models, Combine `debounce` for search, SwiftData for favorites, a `UserDefaults`-backed store and `.preferredColorScheme` for settings.

Flutter's equivalents are Cubit/Bloc, an event transformer, drift's `watch()`, `SharedPreferencesWithCache` and `MaterialApp.themeMode`.
