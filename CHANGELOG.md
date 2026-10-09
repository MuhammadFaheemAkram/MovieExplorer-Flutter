# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project follows [Conventional Commits](https://www.conventionalcommits.org/).

## [Unreleased]

_All four build phases are complete. See [`docs/ROADMAP.md`](docs/ROADMAP.md) for what's next._

## [0.4.0] — 2026-10-09 — Phase 4: Search + Settings + Tests + Polish

### Added
- **Search**
  - `SearchBloc`, with `SearchQueryChanged` / `SearchRetried` events.
  - A custom `debounceRestartable` transformer: blank queries go idle instantly, other queries are debounced by 300 ms, and a newer query cancels the in-flight one.
  - `SearchView`: a Material 3 `SearchBar` with idle / loading / results / no-results / error states.
- **Settings**
  - Domain: `AppThemeMode`, `ContentLanguage`, `AppSettings`.
  - Storage: `SharedPreferencesWithCache`, pre-resolved before `runApp`. `SettingsLocalDataSource` and `SettingsRepositoryImpl` sit on top of it.
  - Four settings use cases.
  - An app-scoped `SettingsCubit` above `MaterialApp.router` that drives `themeMode`.
  - Settings screen: an appearance `SegmentedButton`, a language `DropdownMenu`, and About (`package_info_plus` + `AboutListTile`).
  - A Home content-language badge.
- 38 tests (159 in total): `SearchBloc`, `SettingsRepositoryImpl`, `SettingsCubit`, Search/Settings views, app-level Search and theme flows, and a contrast check for the favorite colors.
- Open-source files: LICENSE (MIT), CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, this CHANGELOG, GitHub issue/PR templates, and `flutter-ci.yml`.
- Docs: ARCHITECTURE, TESTING, LEARNING_NOTES, INTERVIEW_NOTES, ROADMAP, SCREENSHOTS (with light/dark screenshots), and the Phase 4 summary.

### Changed
- `AppColors` gains `onFavorite`. The dark theme's "In favorites" button now uses dark text on its light red (about 6:1 contrast, was 2.8:1 with white).
- Details: the status bar uses light icons and a soft shade over the backdrop, then the theme default once collapsed.
- Generated files are no longer excluded from analysis, so the analyzer reports their compile errors. Their lints are silenced by generator headers (source_gen via `build.yaml`).

### Removed
- The last temporary "Open sample details" button (Search).

## [0.3.0] — 2026-10-09 — Phase 3: drift Favorites + Details

### Added
- **drift database**
  - A `FavoriteMovies` table storing the full movie.
  - A JSON genre converter, and UTC ISO-8601 timestamps (configured in `build.yaml`).
  - `FavoritesDao` with live streams and a transactional toggle.
- Favorites use cases, and favorite-overlay helpers. Every heart follows `watchFavoriteIds()`.
- **Favorites screen:** removal by swipe or heart, optimistic with rollback.
- **Details screen**
  - `@factoryParam` id plus a typed `$extra` preview.
  - Sliver backdrop, `Hero` poster, genre chips, live favorite toggle.
  - An offline fallback to the stored favorite.
- `FavoriteButton`, `MovieRow`, `GenreChip`, `HeroTags`. 51 tests (121 in total).

## [0.2.0] — 2026-10-08 — Phase 2: Models + Fake API + Repository + Home

### Added
- **Error model:** a sealed `AppException` hierarchy, and `Result<T>` (`Ok` / `Err`) using Dart 3.13 primary constructors.
- **Fake API**
  - The iOS edition's bundled JSON catalog, read by `AssetJsonLoader`.
  - `MovieDto` (json_serializable, snake_case, checked).
  - `FakeMovieApiService`: latency, error toggle, title-or-genre search.
- **Domain and data:** freezed `Movie`, `MovieRepository` + `MovieRepositoryImpl`, and the trending/search/details use cases.
- **Home:** `HomeCubit`, a freezed `HomeState`, the 2-column grid, and pull-to-refresh that keeps content and reports failures with a SnackBar.
- `PosterImage`, `RatingBadge`, `MovieCard`. 55 tests (70 in total).

## [0.1.0] — 2026-10-08 — Phase 1: Foundation

### Added
- **Project setup**
  - Flutter 3.47.6 pinned with FVM; Android + iOS.
  - Migrated to the standalone `material_ui` package.
  - Strict analysis.
- **Design system:** Material 3 light/dark themes from the `#4D5CE6` seed, the `AppColors` ThemeExtension, spacing/radius/icon tokens, and the shared state views.
- **Navigation and DI**
  - Typed go_router routes: a `StatefulShellRoute` with four tabs and per-tab Details routes, plus a re-tap-to-pop shell.
  - A `get_it` + `injectable` composition root.
- 15 tests. First README and Phase 1 summary.
