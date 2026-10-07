# 🎬 MovieExplorer (Flutter)

A learning-focused, production-inspired **Flutter** app built with **Flutter 3.47**, **Dart 3.13** and a clean, layered architecture. MovieExplorer lets you browse trending movies, search, view details and save favorites offline. Everything is backed by a **fake network layer**, so it runs with **no API key and no internet connection**.

> **Why this repo exists**
>
> It is the Flutter edition of an app that also exists natively for [Android](https://github.com/MuhammadFaheemAkram/MovieExplorer) and [iOS](https://github.com/MuhammadFaheemAkram/iMovieExplorer).
>
> It is a compact but realistic reference for modern Flutter engineering:
> - Cubit/Bloc state management;
> - the repository pattern;
> - code-generated DI with `get_it` + `injectable`;
> - a drift database;
> - typed `go_router` navigation;
> - a real test suite.
>
> It does all this without being over-engineered. Each phase ships with a beginner-to-intermediate friendly write-up in [`docs/`](docs/) that also shows how the Android and iOS editions solved the same problem.

---

## 📋 Project Status

MovieExplorer is built in **strict, reviewable phases**. Each phase ends with a building app (Android + iOS), a clean analyzer, passing tests, a summary doc and exactly one commit.

| Phase | Scope | Status |
|------:|-------|:------:|
| 1 | Foundation: FVM project, design system base, typed navigation (4-tab shell), DI root | ✅ Done |
| 2 | Models + fake API + repository + Home (trending) | ✅ Done |
| 3 | drift favorites + movie details | ⏳ Next |
| 4 | Search + settings + tests + polish | 🔜 Planned |

---

## ✨ Features (target scope)

- 🔥 Browse **trending movies** in a poster grid, with pull-to-refresh
- 🔎 **Search** by title or genre, debounced with a Bloc event transformer
- 🎞️ Open **movie details**, pushed inside whichever tab you are in
- ❤️ **Favorites** stored with drift; one live stream drives every heart in the app
- 📴 Favorites work **fully offline**
- ⚙️ **Settings**: appearance (System / Light / Dark) and content language
- 🧭 Four tabs, each with **its own back stack**
- ✅ Explicit **loading / empty / error** states everywhere

---

## 🧰 Tech Stack

| Area | Choice | Since |
|------|--------|:-----:|
| Toolchain | Flutter 3.47.6 · Dart 3.13, pinned per project with [FVM](https://fvm.app) (`.fvmrc`) | 1 |
| Platforms | Android · iOS 15+ | 1 |
| UI | [`material_ui`](https://pub.dev/packages/material_ui): Material 3 as a standalone package (new in Flutter 3.47) | 1 |
| Navigation | `go_router` + `go_router_builder` (typed routes, `StatefulShellRoute`) | 1 |
| Dependency injection | `get_it` + `injectable` (code-generated composition root) | 1 |
| State management | `flutter_bloc`: Cubits, plus one event-driven Bloc (Search) | 2 |
| Models | `freezed` + `json_serializable` | 2 |
| Images | `cached_network_image` | 2 |
| Database | `drift` (SQLite) | 3 |
| Preferences | `shared_preferences` (`SharedPreferencesWithCache`) | 4 |
| Testing | `flutter_test`, `bloc_test`, `mocktail` | 1+ |
| Lints | `flutter_lints` + strict analyzer modes | 1 |

---

## 🏛️ Architecture

A clean, layered architecture with a one-directional data flow:

```
lib/
├── app/        → root widget (MaterialApp.router, light/dark themes)
├── core/       → design system, navigation, network, database, storage, common
├── data/       → repository implementations + mappers
├── domain/     → entities, repository contracts, use cases (pure Dart)
├── features/   → one folder per screen (Page + View + Cubit/Bloc)
└── di/         → composition root (get_it + injectable)
```

**Data flow** (live for Home since Phase 2; drift joins in Phase 3):

```
View ──intent──▶ Cubit / Bloc ──▶ UseCase ──▶ MovieRepository ──▶ FakeMovieApiService (bundled JSON)
 ▲                    │                              └──────────▶ drift (favorites)
 └────── state ◀──────┘◀──────── Result / Stream ◀──────────────┘
```

**Navigation** (Phase 1):

```
GoRouter ──▶ StatefulShellRoute ── AppShell (Scaffold + NavigationBar)
               ├─ Home branch       /home        ──▶ /home/movie/:id
               ├─ Search branch     /search      ──▶ /search/movie/:id
               ├─ Favorites branch  /favorites   ──▶ /favorites/movie/:id
               └─ Settings branch   /settings
```

Key rules:
- **Widgets render state; logic lives elsewhere.** Each screen is a Page (provides its Cubit/Bloc) plus a View (renders state, forwards intents).
- **Typed routes only.** No string paths in widgets.
- **Single source of truth.** Persisted data is observed from drift streams.
- **Layer boundaries.** `domain/` is pure Dart (no Flutter, no drift, no JSON), and drift files never import `material_ui`.

---

## 🗂️ Folder Structure

```
MovieExplorer/
├── .fvmrc                              # pinned Flutter version (3.47.6)
├── analysis_options.yaml               # lints + strict analyzer modes
├── assets/json/trending_movies.json    # fake-API catalog (same file as the iOS edition)
├── lib/
│   ├── main.dart                       # binding → configureDependencies() → runApp
│   ├── app/movie_explorer_app.dart
│   ├── core/
│   │   ├── common/                     # Result, AppException, AppConfig
│   │   ├── design_system/              # theme/ (AppTheme, AppColors, tokens) + widgets/
│   │   ├── navigation/                 # app_routes.dart (+ .g.dart), app_router.dart, app_shell.dart
│   │   ├── network/                    # MovieApiService, FakeMovieApiService, AssetJsonLoader, dto/
│   │   ├── database/  storage/         # Phases 3–4
│   ├── data/
│   │   ├── mapper/                     # MovieDto → Movie
│   │   └── repository/                 # MovieRepositoryImpl
│   ├── domain/
│   │   ├── model/                      # Movie (freezed)
│   │   ├── repository/                 # MovieRepository (contract)
│   │   └── usecase/                    # GetTrendingMovies, SearchMovies, GetMovieDetails
│   ├── features/
│   │   ├── home/                       # home_page.dart, home_view.dart, cubit/, widgets/
│   │   └── search/ favorites/ details/ settings/   # placeholders until Phases 3–4
│   └── di/                             # injection.dart (+ .config.dart), app_module.dart
└── test/                               # mirrors lib/, plus helpers/ (fixtures, fakes, pump helpers)
```

---

## ▶️ How to Run

Prerequisites:
- [FVM](https://fvm.app);
- Xcode, for iOS;
- the Android SDK, with Java 17+ (Android Studio's bundled JDK works).

```bash
fvm install            # installs the version pinned in .fvmrc (3.47.6)
fvm flutter pub get
fvm flutter run        # pick an Android emulator or an iOS simulator
```

Generated code (`*.g.dart`, `*.config.dart`) is committed, so the app runs straight after cloning. After changing annotated code, regenerate it:

```bash
fvm dart run build_runner build   # or: watch
```

---

## 🌐 How the Fake API Works

There is no backend. `FakeMovieApiService` implements the same `MovieApiService` contract a real client would:

- It reads [`assets/json/trending_movies.json`](assets/json/trending_movies.json), the same 12-movie catalog the iOS edition bundles, through `AssetJsonLoader`.
- It decodes the catalog into `MovieDto`s with `json_serializable`. The snake_case keys map automatically, and a malformed catalog becomes a `DataFormatException`.
- It simulates latency: 800 ms for trending, 400 ms for search and 500 ms for details.
- Search matches the **title or a genre**, case-insensitively. An unknown id throws `NotFoundException`.
- Setting `AppConfig.simulateNetworkErrors = true` makes every call throw `NetworkException`, so you can walk through each screen's error state.

`MovieRepositoryImpl` maps the DTOs to domain `Movie`s and turns exceptions into `Result` values (`Ok` / `Err`), so nothing above the data layer needs `try`/`catch`. Swapping in a real `dio` client means writing another `MovieApiService` and changing one DI annotation.

---

## ✅ Testing

```bash
fvm flutter analyze
fvm flutter test
```

**70 tests** after Phase 2:
- **Fake API:** runs against the real bundled JSON. Covers search by title and genre, not-found ids, simulated errors, and malformed catalogs.
- **Data layer:** DTO decoding (snake_case, checked errors), mappers, and the repository's error mapping.
- **Use cases:** trending, search (blank queries skip the repository), details.
- **`HomeCubit`** (`bloc_test`): load, empty, error, and refresh keeping content, plus no emits after close.
- **`HomeView`** (widget tests with a `MockCubit`): every state, taps, pull-to-refresh, the refresh-failure SnackBar.
- **Navigation:** tabs, per-tab back stacks, back, re-tap to pop. Fakes are registered in `getIt` for these.
- **Design system:** theme, `AppColors`, `MovieCard`, `RatingBadge`, `PosterImage`, the state widgets, and large-text overflow.

---

## 📱 Same App on Other Platforms

| Edition | Stack | Repo |
|---------|-------|------|
| Android | Kotlin · Jetpack Compose · Hilt · Room | [MuhammadFaheemAkram/MovieExplorer](https://github.com/MuhammadFaheemAkram/MovieExplorer) |
| iOS | Swift 6 · SwiftUI · SwiftData | [MuhammadFaheemAkram/iMovieExplorer](https://github.com/MuhammadFaheemAkram/iMovieExplorer) |
| **Flutter** | Dart · Flutter · Bloc · drift | this repo |

| Concept | Android | iOS | Flutter |
|---|---|---|---|
| UI | Jetpack Compose | SwiftUI | widgets + `material_ui` |
| Screen state | ViewModel + StateFlow | `@Observable` view model | Cubit / Bloc |
| DI | Hilt | `AppEnvironment` | `get_it` + `injectable` |
| Navigation | Navigation Compose | `NavigationStack` + `Route` | `go_router` typed routes |
| Favorites store | Room | SwiftData | drift |
| Settings | DataStore | UserDefaults | `shared_preferences` |
| Debounced search | Flow `debounce` | Combine `debounce` | Bloc event transformer |

---

## 📚 Documentation

- [Phase 1 — Foundation](docs/PHASE_1_SUMMARY.md)
- [Phase 2 — Models + Fake API + Repository + Home](docs/PHASE_2_SUMMARY.md)

---

## 🗺️ Roadmap

- **Phase 3:** drift favorites (DAO, streams, transactions), the Details screen, live hearts everywhere.
- **Phase 4:**
  - `SearchBloc` with debounce + restartable transformers;
  - Settings (`SharedPreferencesWithCache`, app-wide theme);
  - CI and the full open-source docs.

---

## 📄 License

MIT. The license file arrives with the open-source polish in Phase 4.
