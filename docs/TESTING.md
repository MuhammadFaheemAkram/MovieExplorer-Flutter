# Testing

```bash
fvm flutter analyze                                   # no issues allowed
fvm dart format --output=none --set-exit-if-changed .
fvm flutter test                                      # 159 tests
```

CI (`.github/workflows/flutter-ci.yml`) runs the same commands. It also checks that the committed generated code is up to date.

## What is covered

| Area | Tests | Highlights |
|---|---:|---|
| drift (`FavoritesDao`) | 6 | toggle, newest-first (even within one second), live `watch()` streams, converter round-trip |
| Repositories | 14 | DTO and error mapping, favorites streams, offline Details fallback, settings persistence and defaults |
| Fake API + DTO + mappers | 18 | runs against the **real** bundled JSON; title/genre search, not-found, simulated and malformed data |
| Domain + use cases | 16 | favorite overlay, settings models, trending/search/details/favorite use cases |
| `HomeCubit` / `HomeView` | 23 | load/refresh/empty/error, live hearts, no emit after close, SnackBar, language badge |
| `SearchBloc` / `SearchView` | 16 | debounce, blank → idle, restartable cancellation, dedupe, retry, the in-flight re-type bug |
| `FavoritesCubit` / `FavoritesView` | 10 | store-driven list, optimistic removal + rollback, swipe-to-remove |
| `MovieDetailsCubit` / `MovieDetailsView` | 14 | preview vs deep link, quiet refresh, live heart, every state |
| `SettingsCubit` / `SettingsView` | 9 | synchronous initial state, persistence, segments, dropdown, About |
| Design system | 21 | theme + `AppColors` (including WCAG AA contrast of `onFavorite`), cards, rows, hearts, chips, badges, posters, state views, large text |
| App-level navigation | 12 | tabs, per-tab back stacks, re-tap to pop, Search end to end, favorites in sync across tabs, app-wide theme |
| **Total** | **159** | |

## How the tests are built

- **Fakes over mocks.**
  - `FakeMovieRepository` and `FakeSettingsRepository` behave like the real thing. Their `watch…` streams emit the current value on listen, then every change, like drift.
  - Mocks (`mocktail`) appear only in widget tests: `MockCubit` / `MockBloc` from `bloc_test`.
- **Cubits and Blocs** use `blocTest` (`build` / `seed` / `act` / `wait` / `expect` / `verify`).
  - `SearchBloc` takes a short debounce through its `@ignoreParam` constructor parameter, so the suite stays fast.
  - A `Completer` "gate" in the fake repository keeps a request in flight, to test cancellation and emitting after close.
- **Views** are pumped with a mocked Cubit/Bloc on a **phone-sized surface** (`tester.usePhoneSurface()`), because the default test window is 800×600. `whenListen` drives state sequences such as the refresh SnackBar or an optimistic removal.
- **drift** runs on `NativeDatabase.memory()`, a fresh in-memory SQLite database per test, closed in `tearDown`.
- **Preferences** use `InMemorySharedPreferencesAsync`, which exercises the real `SharedPreferencesWithCache` code.
- **App-level tests** pump the real `MovieExplorerApp`. `registerTestDependencies()` puts fakes in `getIt` (Search with no debounce), and `tearDown(getIt.reset)` cleans up.
- **Bounded waits.** `nextEvent()` wraps `StreamQueue.next` in a timeout, so a broken stream fails fast instead of hanging the suite.

## Gotchas worth knowing

- Wait for a drift `watch()` stream's first value before writing. Otherwise you only ever see the after-write state.
- `package:async` exports its own `Result`, so import it with `show StreamQueue`.
- A Cubit drops a repeated state, except on its very first `emit`. Assert exact sequences with that in mind.
- `pumpAndSettle()` never settles while a spinner is on screen. Use `pump()` in loading states.

These, and more, are recorded as verified traps in the shared Flutter conventions (`00-CONVENTIONS.md` §11).
