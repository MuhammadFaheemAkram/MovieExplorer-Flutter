import 'dart:async';

import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';

/// In-memory [MovieRepository] for Cubit, use-case and app-level tests.
///
/// It is a hand-written fake rather than a mock, so tests read as behaviour:
/// set what the "backend" returns, act, then assert on state.
class FakeMovieRepository implements MovieRepository {
  FakeMovieRepository({this.movies = const [], this.failure});

  /// What the backend returns.
  List<Movie> movies;

  /// When non-null, every call fails with this exception.
  AppException? failure;

  /// When non-null, calls wait for it to complete. Lets a test observe
  /// in-flight states or close a Cubit mid-request.
  Completer<void>? gate;

  int trendingCalls = 0;
  final searchQueries = <String>[];

  @override
  Future<Result<List<Movie>>> getTrendingMovies() async {
    trendingCalls++;
    return _respond(() => movies);
  }

  @override
  Future<Result<List<Movie>>> searchMovies(String query) async {
    searchQueries.add(query);
    final needle = query.toLowerCase();
    return _respond(
      () => [
        for (final movie in movies)
          if (movie.title.toLowerCase().contains(needle)) movie,
      ],
    );
  }

  @override
  Future<Result<Movie>> getMovieDetails(int id) async {
    await gate?.future;
    final failure = this.failure;
    if (failure != null) return Err(failure);
    for (final movie in movies) {
      if (movie.id == id) return Ok(movie);
    }
    return const Err(NotFoundException());
  }

  @override
  Stream<List<Movie>> watchFavoriteMovies() => Stream.value(const []);

  @override
  Stream<Set<int>> watchFavoriteIds() => Stream.value(const {});

  @override
  Future<Result<void>> toggleFavorite(Movie movie) async => const Ok(null);

  Future<Result<T>> _respond<T>(T Function() value) async {
    await gate?.future;
    final failure = this.failure;
    return failure == null ? Ok(value()) : Err(failure);
  }
}
