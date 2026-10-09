import 'package:drift/drift.dart';
import 'package:movie_explorer/core/database/converters/string_list_converter.dart';

/// Favorited movies, stored in full, so the Favorites screen and Details work
/// offline.
///
/// The row class name is explicit: drift would otherwise singularize
/// `FavoriteMovies` naively into `FavoriteMovy`.
@DataClassName('FavoriteMovieRow')
class FavoriteMovies extends Table {
  IntColumn get id => integer()();

  TextColumn get title => text()();

  TextColumn get overview => text()();

  RealColumn get rating => real()();

  TextColumn get releaseYear => text()();

  TextColumn get posterUrl => text().nullable()();

  TextColumn get backdropUrl => text().nullable()();

  TextColumn get genres => text().map(const StringListConverter())();

  /// When the movie was favorited (UTC); orders the list newest first.
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
