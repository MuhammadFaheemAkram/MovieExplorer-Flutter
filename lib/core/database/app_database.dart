import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:movie_explorer/core/database/converters/string_list_converter.dart';
import 'package:movie_explorer/core/database/daos/favorites_dao.dart';
import 'package:movie_explorer/core/database/tables/favorite_movies_table.dart';

part 'app_database.g.dart';

/// The app's SQLite database: the single source of truth for favorites.
///
/// This file and the rest of `core/database/` never import `material_ui` or
/// the JSON packages. drift exports `Table`, `Column` and `JsonKey`, and those
/// names would clash (conventions §11.1).
@DriftDatabase(tables: [FavoriteMovies], daos: [FavoritesDao])
class AppDatabase extends _$AppDatabase {
  /// Opens `movie_explorer.sqlite` in the app's documents directory. Tests pass
  /// an in-memory [executor] instead.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'movie_explorer'));

  /// Bump this and add a migration whenever a table changes.
  @override
  int get schemaVersion => 1;
}
