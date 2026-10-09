# Phase 3 — drift Favorites + Details

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 3, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions solved the same problems.

---

## 🎯 Phase Goal

Phase 3 adds **on-device persistence** and makes it the **single source of truth** for favorites:

- favorites are stored in a **drift** (SQLite) database, so they survive restarts and work offline;
- every heart in the app (Home cards, the Details button, Favorites rows) follows **one stream** of favorite ids, so a change anywhere shows up everywhere instantly;
- the real **Details** screen arrives, with a collapsing backdrop, a `Hero` poster, genres and a live favorite toggle.

The phase also introduces the patterns needed when UI state is *derived from a stream*:
- managing stream subscriptions inside a Cubit;
- optimistic updates;
- not re-emitting identical states.

---

## 🧱 What Was Implemented

- **Packages:** `drift` and `drift_flutter`; dev: `drift_dev` and `async` (for `StreamQueue` in tests).
- **`build.yaml`:** drift's `store_date_time_values_as_text` option, so `DateTime`s are stored as ISO-8601 text with microsecond precision instead of whole seconds.
- **Database** (`core/database/`)
  - `AppDatabase`: schema version 1, opened with `driftDatabase(name: 'movie_explorer')`. Tests pass an in-memory executor instead.
  - `FavoriteMovies` table:
    - explicit `@DataClassName('FavoriteMovieRow')`;
    - stores the full movie plus a UTC `addedAt`;
    - genres go through `StringListConverter`, a JSON `TypeConverter`.
  - `FavoritesDao`:
    - `watchAll()`: newest first;
    - `watchIds()`: a cheaper single-column `selectOnly` query;
    - `findById()`;
    - `toggle()`: runs inside a **transaction**.
- **Dependency injection**
  - `AppModule` registers `AppDatabase` and `FavoritesDao` as lazy singletons. There is one database per app, because drift's change notifications only work within a single database instance.
  - `MovieDetailsCubit` is registered as `factoryParam<MovieDetailsCubit, int, Movie?>`.
- **Data**
  - `FavoriteMovieRow ↔ Movie` mappers, in their own file so the drift imports stay apart from the JSON mapper.
  - `MovieRepositoryImpl` gains:
    - the favorites streams;
    - a toggle that writes UTC timestamps;
    - the Details **offline fallback**: if the API fails, the stored favorite is returned. It uses the pattern `Ok(value: final row?)`.
- **Domain**
  - The `withFavoriteFrom` / `withFavoritesFrom` overlay helpers.
  - `WatchFavoriteMoviesUseCase`, `WatchFavoriteIdsUseCase` and `ToggleFavoriteUseCase`.
- **Design system**
  - New: `FavoriteButton` (its tooltip doubles as the screen-reader label), `MovieRow` (optional trailing widget and hero), `GenreChip`, and `HeroTags`.
  - `MovieCard` gains a `Hero` poster and an optional heart.
  - Chips get a pill shape in the theme.
- **Home**
  - `HomeCubit` subscribes to the favorite ids, overlays the hearts, and exposes `toggleFavorite`.
  - The grid shows hearts and Hero tags.
  - Taps pass the movie as a **preview** through the route's `$extra`.
- **Favorites**
  - `FavoritesState` has loading, empty and loaded (there is no error case: the data is local).
  - `FavoritesCubit` renders the drift stream. Removal is **optimistic, with rollback**.
  - The view uses `Dismissible` swipe-to-remove plus a heart button.
  - The temporary sample button is gone.
- **Details**
  - `MovieDetailsCubit`:
    - receives the id and the optional preview through `@factoryParam`;
    - with a preview it shows the movie at once and refreshes quietly;
    - without one (a deep link) it shows the loading state;
    - its heart is live.
  - `MovieDetailsView`:
    - a `SliverAppBar` backdrop, with a back button kept readable by a scrim;
    - the `Hero` poster, title, rating and year;
    - genre chips, the favorite toggle and the overview.
- **Routes:** the three Details routes accept a typed `Movie? $extra` preview.
- **Tests:** 51 new, **121 in total**.
- **Docs:**
  - README: a "How Local Persistence Works" section;
  - this summary;
  - four new *verified* traps in `00-CONVENTIONS.md` §11.11–11.14.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **drift**
  - The table DSL: columns, a nullable column, a primary key, `@DataClassName`.
  - A `TypeConverter` and the `DateTime` storage modes (set through `build.yaml` builder options).
  - `@DriftDatabase`, a `@DriftAccessor` DAO, and their generated mixins.
  - Queries: `select` / `selectOnly`, `where`, `orderBy`, `getSingleOrNull`.
  - Writing: companions and `Value`, and `transaction`.
  - **`watch()` streams**, which re-run automatically when a table they read changes.
  - In-memory testing with `NativeDatabase.memory()`.
- **Streams inside Cubits**
  - Subscribe in the constructor and cancel in `close()`.
  - Overlay derived state onto the current state.
  - Emit only on a real change: Bloc drops a repeated state, *except on the very first emit*.
- **Optimistic UI**
  - Update the state first, write second, and roll back on failure.
  - Why `Dismissible` needs this: a dismissed row must never be rebuilt into the list.
- **`Hero` animations** across a push inside a go_router branch navigator. Both Hero widgets must exist while the transition runs, so the destination needs content immediately. Passing a **preview through the typed route's `$extra`** provides it.
- **injectable `@factoryParam`** with two runtime parameters: `getIt<MovieDetailsCubit>(param1: id, param2: preview)`, and `registerFactoryParam` in tests.
- **Dart 3 patterns**
  - `if (state case MovieDetailsLoaded(:final movie))`;
  - the null-check pattern `Ok(value: final row?)`;
  - guarded cases `case Err(...) when !hasContent`;
  - collection `for` / `if` in list literals.
- **Slivers:** `CustomScrollView` + `SliverAppBar` + `FlexibleSpaceBar` + `SliverList.list`. Also a styled `BackButton`, `Wrap` + `Chip`, and `FilledButton.icon` / `tonalIcon`.
- **Testing**
  - `StreamQueue` with **bounded waits**, and in-memory SQLite.
  - Fakes that mimic drift's `watch()` (emit on listen, then on every change).
  - `MockCubit` + `whenListen` driven by a `StreamController`, to simulate an optimistic emission.
  - `registerFallbackValue` for mocktail's `any()`.
  - End-to-end widget tests across tabs.
- **Import hygiene:** `package:async` exports its own `Result`, so tests import `show StreamQueue`.

---

## 🔁 Data Flow (this phase)

```
Heart tap (Home card · Details button · Favorites row)
  └─▶ Cubit.toggleFavorite / remove ─▶ ToggleFavoriteUseCase ─▶ MovieRepositoryImpl.toggleFavorite
                                                                  └─▶ FavoritesDao.toggle (transaction) ─▶ SQLite

SQLite change ─▶ drift re-runs every watching query
  ├─▶ watchIds()  ─▶ WatchFavoriteIdsUseCase    ─▶ HomeCubit · MovieDetailsCubit ── overlay ─▶ hearts
  └─▶ watchAll()  ─▶ WatchFavoriteMoviesUseCase ─▶ FavoritesCubit ─▶ list

Card / row tap ─▶ XMovieDetailsRoute(id, $extra: movie).push(context) ─▶ MovieDetailsPage
  └─▶ getIt<MovieDetailsCubit>(param1: id, param2: preview)..load()
        preview? ── yes ─▶ loaded(preview) at once (the Hero has a target) ─▶ quiet refresh
                 └─ no ──▶ loading ─▶ GetMovieDetails: API, else the stored favorite ─▶ loaded / error
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `build.yaml` | drift option: `DateTime`s as ISO-8601 text. |
| `lib/core/database/app_database.dart` (+ `.g.dart`) | The SQLite database (drift). |
| `lib/core/database/tables/favorite_movies_table.dart` | The favorites table definition. |
| `lib/core/database/daos/favorites_dao.dart` (+ `.g.dart`) | Favorites queries, streams, transactional toggle. |
| `lib/core/database/converters/string_list_converter.dart` | `List<String>` ↔ JSON text. |
| `lib/data/mapper/favorite_movie_mappers.dart` | Row ↔ domain mapping. |
| `lib/domain/model/movie_favorites.dart` | The favorite-overlay helpers. |
| `lib/domain/usecase/{watch_favorite_movies,watch_favorite_ids,toggle_favorite}_use_case.dart` | Favorites use cases. |
| `lib/core/design_system/widgets/{favorite_button,movie_row,genre_chip,hero_tags}.dart` | New shared UI. |
| `lib/features/favorites/**` | Favorites Page, View, Cubit and state. |
| `lib/features/details/**` | Details Page, View, Cubit and state. |
| `test/core/database/favorites_dao_test.dart` | In-memory drift tests. |
| `test/helpers/stream_helpers.dart` | `nextEvent()`: a bounded `StreamQueue` wait. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `AppDatabase` | drift database | Owns the SQLite connection and schema | `core/database`: infrastructure |
| `FavoriteMovies` / `FavoriteMovieRow` | table / generated row class | The stored favorite | `core/database` |
| `StringListConverter` | `TypeConverter` | Stores lists in a TEXT column | `core/database/converters` |
| `FavoritesDao` | `DatabaseAccessor` | Queries, streams, transactional toggle | `core/database/daos` |
| `MovieFavorites`, `MovieListFavorites` | extensions | Overlay `isFavorite` from a set of ids | `domain/model`: pure business rule |
| `WatchFavorite…UseCase`, `ToggleFavoriteUseCase` | use cases | Favorites operations | `domain/usecase` |
| `FavoritesCubit` / `FavoritesState` | Cubit / sealed union | Renders the store; optimistic removal | `features/favorites/cubit` |
| `MovieDetailsCubit` / `MovieDetailsState` | Cubit / sealed union | Preview → refresh, live heart | `features/details/cubit` |
| `FavoriteButton`, `MovieRow`, `GenreChip`, `HeroTags` | widgets / constants | Reusable movie UI | `core/design_system` |

---

## 🌱 Folder Structure Changes

- **New:** `lib/core/database/{tables,daos,converters}/`, `lib/features/favorites/cubit/`, `lib/features/details/cubit/` and `build.yaml`.
- **Tests:** `test/core/database/`, `test/domain/model/`, `test/features/favorites/` and `test/features/details/`.
- **Removed:** the last placeholder `.gitkeep` (in `core/database/`).

---

## 🤖🍏 Android / iOS Comparison

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Local store | Room `@Entity` (genres joined with `|`) + `@Dao` | SwiftData `@Model` + a `@ModelActor` store | drift table (JSON `TypeConverter`) + DAO |
| Observing changes | DAO returns `Flow` | The actor pushes snapshots into an `AsyncStream` | drift `watch()`: automatic table-change tracking |
| Toggle | check, then insert/delete | actor-serialized check + write | one **transaction** in the DAO |
| Favorites order | title A–Z | `dateAdded` descending | `addedAt` descending (UTC ISO-8601 text) |
| Home hearts | repository `combine(cache, favoriteIds)` | view models observe favorites | Cubits overlay `watchFavoriteIds()` |
| Details heart | flipped locally after a toggle | observed from the store | observed from the store |
| Details argument | navigation arg + `SavedStateHandle` | `Route.movieDetails(id:)` + a factory | typed route id + `@factoryParam`; preview via `$extra` |
| Swipe to remove | n/a (remove button) | `onDelete` → toggle | `Dismissible` + optimistic Cubit update + rollback |
| Persistence tests | in-memory Room | in-memory `ModelContainer` | `NativeDatabase.memory()` |

The closest match is iOS:
- both editions observe one store, and both put the favorite overlay in the screen's state holder;
- drift's `watch()` replaces the hand-written continuation bookkeeping in the iOS `FavoritesStore` actor.

---

## 🎤 Interview Notes

**Q: Why drift for favorites, rather than shared_preferences, Hive or Isar?**
A: Favorites are relational, queryable data that must be *observed*. drift offers typed SQL generated at compile time, reactive `watch()` queries, transactions, migrations and active maintenance. shared_preferences is for small settings; Hive has no real queries; the original Isar is no longer maintained.

**Q: How does drift know when to re-emit a `watch()` stream?**
A: It records which tables each query reads. Any write made through the same database instance to one of those tables re-runs the query. That's why the app keeps a single `AppDatabase`: writes from another instance (or another process) would go unnoticed.

**Q: Why store the whole movie instead of just its id?**
A: Offline. The Favorites list and the Details fallback must render without the network, so the row holds everything the UI needs.

**Q: Why derive every heart from one stream of ids?**
A: A single source of truth. When each screen holds its own copy of favorite state, the copies drift apart. Here the screens hold no favorite state at all; they overlay the latest ids from the store, so they can't disagree.

**Q: How do you manage a stream subscription in a Cubit?**
A: Subscribe in the constructor, keep the `StreamSubscription`, and cancel it in an overridden `close()` before calling `super.close()`. In a Bloc, `emit.forEach` / `emit.onEach` does this inside a handler.

**Q: Cubits skip duplicate states, so why compare before emitting?**
A: The skip only applies after the first emit. A Cubit that *starts* in a content state (Details with a preview) re-emits an identical state on its first overlay update. An explicit `if (updated != current)` makes the intent clear and avoids a wasted rebuild.

**Q: What is an optimistic update, and why does `Dismissible` need one?**
A: You update the UI before the write confirms it, and roll back if the write fails. A dismissed `Dismissible` throws if the list rebuilds while it is still in it. With an async source of truth there is a gap before the store confirms, so the Cubit removes the row from state immediately.

**Q: How do Hero animations work here, and why the `$extra` preview?**
A: Two `Hero`s with the same tag, one on each route, fly between each other during the push. The destination must already exist when the transition starts. A Details screen that first shows a spinner has no hero to fly to, so the list passes its copy of the movie as a typed `$extra`. Deep links have no extra and simply fall back to loading.

**Q: How do runtime values such as a movie id get into a DI-built Cubit?**
A: With injectable's `@factoryParam`. The generated factory takes them as `param1` / `param2`, while the rest are injected as usual. Without it, the Page would have to construct the Cubit by hand.

**Q: Why is the DAO's toggle wrapped in a transaction?**
A: It is a read-decide-write sequence. Without a transaction, two quick toggles could both see "absent" and both insert (or both delete).

---

## 📝 Learning Checklist

- ✅ Define drift tables, converters and DAOs, and generate them
- ✅ Observe queries with `watch()` and write inside transactions
- ✅ Test drift with an in-memory database and bounded `StreamQueue` waits
- ✅ Keep one source of truth and derive UI state from its stream
- ✅ Manage stream subscriptions in Cubits (`close()`)
- ✅ Apply optimistic updates with rollback
- ✅ Build a sliver-based details screen with a `Hero` transition
- ✅ Pass runtime parameters through injectable (`@factoryParam`)
- ✅ Pass typed `$extra` data through go_router routes
- ⬜ Debounce and cancel with Bloc event transformers (Phase 4)
- ⬜ Persist settings with `SharedPreferencesWithCache` (Phase 4)
- ⬜ Drive app-wide theme from an app-scoped Cubit (Phase 4)

---

## 🚀 Future Improvements

- **Phase 4:**
  - Search (replacing the last temporary sample button) and Settings;
  - a contrast pass for the status bar over Details backdrops (`systemOverlayStyle`);
  - a dark-mode check on every screen.
- **Undo for swipe-to-remove:** the row would need to be restored with its original `addedAt`.
- **Schema migrations:** when the table changes, bump `schemaVersion` and add a `MigrationStrategy`. `drift_dev` can dump schemas and generate migration tests.
- **Caching trending movies in drift** would make Home work offline as well (the core idea of the RoamReady project).
