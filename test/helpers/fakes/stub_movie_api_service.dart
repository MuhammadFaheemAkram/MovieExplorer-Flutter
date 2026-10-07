import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/network/dto/movie_dto.dart';
import 'package:movie_explorer/core/network/movie_api_service.dart';

/// A [MovieApiService] that returns canned DTOs or throws [error], for testing
/// the repository's mapping and error handling in isolation.
class StubMovieApiService implements MovieApiService {
  StubMovieApiService({this.movies = const [], this.error});

  List<MovieDto> movies;

  /// When non-null, every call throws it.
  Object? error;

  @override
  Future<List<MovieDto>> fetchTrendingMovies() async {
    _throwIfConfigured();
    return movies;
  }

  @override
  Future<List<MovieDto>> searchMovies(String query) async {
    _throwIfConfigured();
    return movies;
  }

  @override
  Future<MovieDto> fetchMovieDetails(int id) async {
    _throwIfConfigured();
    return movies.firstWhere(
      (movie) => movie.id == id,
      orElse: () => throw const NotFoundException(),
    );
  }

  void _throwIfConfigured() {
    final error = this.error;
    if (error != null) throw error;
  }
}
