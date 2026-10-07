import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';

/// The single seam between features and movie data sources.
///
/// It hides the fake API (and, from Phase 3, the drift favorites store) behind
/// one contract that lives in the domain layer, so Cubits only ever see domain
/// types. One-shot reads return a [Result]; data that changes over time is
/// exposed as a `Stream`.
abstract interface class MovieRepository {
  Future<Result<List<Movie>>> getTrendingMovies();

  Future<Result<List<Movie>>> searchMovies(String query);

  Future<Result<Movie>> getMovieDetails(int id);

  /// Favorited movies, newest first, with `isFavorite = true`. Backed by drift
  /// from Phase 3.
  Stream<List<Movie>> watchFavoriteMovies();

  /// Ids of all favorited movies. This one stream drives every heart in the
  /// app.
  Stream<Set<int>> watchFavoriteIds();

  /// Adds [movie] to favorites, or removes it if it is already there.
  Future<Result<void>> toggleFavorite(Movie movie);
}
