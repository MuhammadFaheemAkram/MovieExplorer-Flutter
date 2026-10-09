import 'package:drift/drift.dart';
import 'package:movie_explorer/core/database/app_database.dart';
import 'package:movie_explorer/domain/model/movie.dart';

// Mapping between drift rows and the domain model. It lives in its own file
// because it imports drift, which must stay apart from the JSON/DTO mapper
// (conventions §11.1).

extension FavoriteMovieRowMapper on FavoriteMovieRow {
  /// A stored row is a favorite by definition.
  Movie toDomain() => Movie(
    id: id,
    title: title,
    overview: overview,
    rating: rating,
    releaseYear: releaseYear,
    posterUrl: posterUrl,
    backdropUrl: backdropUrl,
    genres: genres,
    isFavorite: true,
  );
}

extension MovieFavoriteCompanion on Movie {
  /// The full movie as a row to insert, so it stays browsable offline.
  FavoriteMoviesCompanion toFavoriteCompanion({required DateTime addedAt}) =>
      FavoriteMoviesCompanion.insert(
        id: Value(id),
        title: title,
        overview: overview,
        rating: rating,
        releaseYear: releaseYear,
        posterUrl: Value(posterUrl),
        backdropUrl: Value(backdropUrl),
        genres: genres,
        addedAt: addedAt,
      );
}
