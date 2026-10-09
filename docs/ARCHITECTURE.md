# Architecture

MovieExplorer uses a layered **clean architecture with MVVM-style presentation**: Cubits and Blocs play the ViewModel role. Data flows one way: widgets send intents down, and immutable state flows back up.

```
┌──────────────────────────── presentation (features/) ────────────────────────────┐
│  Page (wires DI + navigation) ─▶ View (renders state) ─▶ Cubit / Bloc             │
└───────────────────────────────────────┬──────────────────────────────────────────┘
                                        │ use cases (domain/usecase)
┌───────────────────────────────────────▼──────────────────────────────────────────┐
│  domain/  (pure Dart)   Movie · AppSettings · Result-returning repository contracts │
└───────────────────────────────────────┬──────────────────────────────────────────┘
                                        │ implemented by
┌───────────────────────────────────────▼──────────────────────────────────────────┐
│  data/   MovieRepositoryImpl · SettingsRepositoryImpl · mappers                    │
└──────────────┬───────────────────────────────┬───────────────────────┬───────────┘
   core/network│ (fake API, DTOs)   core/database│ (drift)   core/storage│ (prefs)
               ▼                               ▼                       ▼
     assets/json/trending_movies.json     movie_explorer.sqlite   SharedPreferencesWithCache
```

## Layers and their rules

| Layer | Contains | May import | Must not import |
|---|---|---|---|
| `domain/` | entities (freezed), repository contracts, use cases | `core/common` (`Result`, `AppException`) | Flutter, drift, JSON, `data/` |
| `data/` | repository implementations, mappers | `domain/`, `core/*` | features |
| `core/network` | `MovieApiService`, the fake service, DTOs, asset loader | `core/common`, JSON packages | `material_ui`, drift |
| `core/database` | `AppDatabase`, tables, DAOs, converters | drift | `material_ui`, JSON packages (name clashes) |
| `core/storage` | `SettingsLocalDataSource` | `shared_preferences` | everything above it |
| `core/design_system` | theme, tokens, shared widgets | `material_ui`, `domain/model` | features, routes |
| `core/navigation` | typed routes, router, shell | features' Pages | |
| `features/<feature>` | Page, View, Cubit/Bloc, state | `domain/`, design system, routes | `data/` |
| `di/` | composition root | everything | |

## State management

| Screen | Holder | Scope | Why |
|---|---|---|---|
| Home | `HomeCubit` | screen | plain intents (`load`, `refresh`, `toggleFavorite`) |
| Search | **`SearchBloc`** | screen | needs **event transformers**: debounce + restartable |
| Favorites | `FavoritesCubit` | screen | renders a drift stream; optimistic removal |
| Details | `MovieDetailsCubit` | screen (`@factoryParam` id + preview) | preview → quiet refresh; live heart |
| Settings | `SettingsCubit` | **app** (above `MaterialApp.router`) | drives `themeMode` and the Home badge |

The rule: **Cubit by default; Bloc when explicit events and transformers add value.** Every state is a freezed sealed union (or an immutable value), rendered with an exhaustive `switch`.

## Single source of truth

- **Favorites:** drift is the source.
  - `watchFavoriteIds()` drives every heart: Home and Details overlay `isFavorite` from it.
  - `watchFavoriteMovies()` drives the Favorites list.
  - No screen stores favorite flags of its own.
- **Settings:** `SettingsRepositoryImpl` keeps the current value and publishes changes. `SettingsCubit` mirrors it, and everything else reads the Cubit.
- **Network data** (trending, search, details) is fetched on demand. It never overrides favorite state.

## Error handling

- Data sources throw subtypes of a sealed `AppException`: `NetworkException`, `NotFoundException`, `DataFormatException` or `UnknownException`. Each carries a user-facing `message`.
- Repositories catch them and return `Result<T>` (`Ok` / `Err`), so callers must handle both cases with an exhaustive `switch`.
- Unexpected exceptions are logged and mapped to `UnknownException`.

## Dependency injection

`get_it` + `injectable`. `configureDependencies()` is generated, and awaited in `main()`.

| Registration | Used for |
|---|---|
| `@preResolve` + `@lazySingleton` | `SharedPreferencesWithCache` and `PackageInfo`, which are awaited before `runApp` |
| `@lazySingleton` | infrastructure: asset bundle and loader, API service, `AppDatabase` / `FavoritesDao`, repositories |
| `@injectable` (factory) | use cases, Cubits and Blocs (each screen owns its instance; `BlocProvider` closes it) |
| `factoryParam` | `MovieDetailsCubit(movieId, preview)` |

`getIt` is used only in `main.dart`, the router and Page widgets. Everything else gets its dependencies through its constructor.

## Navigation

- **go_router 18 with typed routes** (`go_router_builder`).
- One `@TypedStatefulShellRoute` with four branches. Each tab has its own `Navigator`, and the branches are kept alive offstage.
- **Details is a child route of each list tab**, so it opens inside the current tab: `/home/movie/:id`, `/search/movie/:id` and `/favorites/movie/:id`.
- Lists pass the movie they already have as a typed **`$extra` preview**. Details renders it at once (and the `Hero` has a target), then refreshes. A deep link has no preview and starts in the loading state.

## Key decisions

| Decision | Alternative | Why |
|---|---|---|
| `material_ui` package | in-SDK `flutter/material.dart` | Material was decoupled in Flutter 3.47, and the in-SDK copy is being deprecated |
| Repository returns `Result` | throwing to the UI | failure is part of the type; the exhaustive `switch` forces handling |
| freezed sealed states | hand-written classes | value equality, `copyWith`, exhaustive unions |
| drift | Hive / Isar / sqflite | typed SQL, reactive queries, transactions, migrations, maintained |
| `SharedPreferencesWithCache` | `SharedPreferencesAsync` | synchronous reads after init, so there is no theme flash on start |
| Optimistic Favorites removal | waiting for drift | a dismissed `Dismissible` must not be rebuilt into the list |
| Generated files committed | generating in CI | clone-and-run; readers can see what the generators produce |

See the per-phase write-ups in this folder for the reasoning behind each piece.
