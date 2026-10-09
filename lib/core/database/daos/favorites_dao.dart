import 'package:drift/drift.dart';
import 'package:movie_explorer/core/database/app_database.dart';
import 'package:movie_explorer/core/database/tables/favorite_movies_table.dart';

part 'favorites_dao.g.dart';

/// Every favorites query in one place (the drift equivalent of a Room DAO).
///
/// The `watch…` methods return streams that re-emit whenever the table changes.
/// That is how every screen stays in sync without being told to refresh.
@DriftAccessor(tables: [FavoriteMovies])
class FavoritesDao extends DatabaseAccessor<AppDatabase>
    with _$FavoritesDaoMixin {
  FavoritesDao(super.attachedDatabase);

  /// All favorites, newest first.
  Stream<List<FavoriteMovieRow>> watchAll() {
    final query = select(favoriteMovies)
      ..orderBy([(movie) => OrderingTerm.desc(movie.addedAt)]);
    return query.watch();
  }

  /// Ids of all favorites. It reads only the id column, which is cheaper than
  /// loading whole rows.
  Stream<Set<int>> watchIds() {
    final query = selectOnly(favoriteMovies)..addColumns([favoriteMovies.id]);
    return query
        .map((row) => row.read(favoriteMovies.id)!)
        .watch()
        .map((ids) => ids.toSet());
  }

  Future<FavoriteMovieRow?> findById(int id) {
    final query = select(favoriteMovies)..where((movie) => movie.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Removes [movie] if it is a favorite, otherwise inserts it. Returns whether
  /// it is a favorite afterwards.
  ///
  /// The check and the write run in one transaction, so two quick taps can't
  /// interleave.
  Future<bool> toggle(FavoriteMoviesCompanion movie) {
    return transaction(() async {
      final removed = await (delete(
        favoriteMovies,
      )..where((row) => row.id.equals(movie.id.value))).go();
      if (removed > 0) return false;
      await into(favoriteMovies).insert(movie);
      return true;
    });
  }
}
