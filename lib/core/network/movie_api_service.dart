import 'package:movie_explorer/core/network/dto/movie_dto.dart';

/// Retrofit-style contract for the movie backend.
///
/// The app depends on this interface, not on a transport. Today
/// `FakeMovieApiService` implements it with bundled JSON. A real `dio` client
/// could implement it later with no change to any caller. Implementations
/// throw `AppException`s, and the repository turns them into `Result`s.
abstract interface class MovieApiService {
  Future<List<MovieDto>> fetchTrendingMovies();

  /// Movies whose title or genre contains [query] (case-insensitive).
  Future<List<MovieDto>> searchMovies(String query);

  Future<MovieDto> fetchMovieDetails(int id);
}
