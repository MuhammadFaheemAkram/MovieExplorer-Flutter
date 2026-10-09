import 'dart:async';

import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';

/// In-memory [MovieRepository] for Cubit, use-case and app-level tests.
///
/// It is a hand-written fake rather than a mock, so tests read as behaviour:
/// set what the "backend" returns, act, then assert on state. Favorites behave
/// like drift: the `watch…` streams emit the current value on listen, then
/// again after every change.
class FakeMovieRepository implements MovieRepository {
  FakeMovieRepository({
    this.movies = const [],
    this.failure,
    Iterable<Movie> favorites = const [],
  }) {
    for (final movie in favorites) {
      _favorites[movie.id] = movie;
    }
  }

  /// What the backend returns.
  List<Movie> movies;

  /// When non-null, every network call fails with this exception.
  AppException? failure;

  /// When non-null, [toggleFavorite] fails with this exception.
  AppException? toggleFailure;

  /// When non-null, network calls wait for it to complete. Lets a test observe
  /// in-flight states or close a Cubit mid-request.
  Completer<void>? gate;

  int trendingCalls = 0;
  final searchQueries = <String>[];
  final toggledIds = <int>[];

  // Insertion-ordered, so the newest favorite is last.
  final _favorites = <int, Movie>{};
  final _favoritesChanged = StreamController<void>.broadcast(sync: true);

  /// The stored favorites, newest first, as the store returns them.
  List<Movie> get favoriteMovies => [
    for (final movie in _favorites.values.toList().reversed)
      movie.copyWith(isFavorite: true),
  ];

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
  Stream<List<Movie>> watchFavoriteMovies() => _watch(() => favoriteMovies);

  @override
  Stream<Set<int>> watchFavoriteIds() => _watch(() => _favorites.keys.toSet());

  @override
  Future<Result<void>> toggleFavorite(Movie movie) async {
    toggledIds.add(movie.id);
    final failure = toggleFailure;
    if (failure != null) return Err(failure);
    if (_favorites.remove(movie.id) == null) _favorites[movie.id] = movie;
    _favoritesChanged.add(null);
    return const Ok(null);
  }

  Future<void> dispose() => _favoritesChanged.close();

  Future<Result<T>> _respond<T>(T Function() value) async {
    await gate?.future;
    final failure = this.failure;
    return failure == null ? Ok(value()) : Err(failure);
  }

  /// A stream that emits [read] on listen and after every change, like drift.
  Stream<T> _watch<T>(T Function() read) {
    StreamSubscription<void>? changes;
    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        controller.add(read());
        changes = _favoritesChanged.stream.listen(
          (_) => controller.add(read()),
        );
      },
      onCancel: () async {
        await changes?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }
}
