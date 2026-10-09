# Roadmap

All four build phases are complete. These are natural next steps, roughly in order of learning value.

## Done

- ✅ **Phase 1 — Foundation:** FVM toolchain, `material_ui`, design system, typed 4-tab navigation, DI root.
- ✅ **Phase 2 — Fake API + Home:** `Result`/`AppException`, bundled JSON, repository, `HomeCubit` grid.
- ✅ **Phase 3 — drift favorites + Details:** single source of truth for hearts, offline Favorites, Hero details.
- ✅ **Phase 4 — Search + Settings:** debounced/restartable `SearchBloc`, app-wide theme and language, CI, docs.

## Next ideas

- **Real backend:**
  - a `DioMovieApiService` against TMDB, with the API key injected at build time (`--dart-define-from-file`, never committed);
  - the repository and UI stay unchanged.
- **Offline Home:** cache trending movies in drift with a freshness policy (stale-while-revalidate).
- **Localization:** `flutter_localizations` + `gen-l10n` (ARB files), so the content-language setting actually translates the UI, including right-to-left layout for العربية and اردو.
- **Integration tests:** `integration_test` flows on a device, plus golden tests for the design-system widgets.
- **Adaptive layout:** a `NavigationRail` on tablets and in landscape, with list–detail side by side.
- **Undo** for swipe-to-remove, restoring the original `addedAt`.
- **Schema migrations:** a drift `MigrationStrategy` with generated migration tests, once the table changes.
- **CI:** an iOS simulator build on a macOS runner, plus coverage reporting.
- **Accessibility audit:** screen-reader traversal order, contrast checks and larger tap targets where needed.
