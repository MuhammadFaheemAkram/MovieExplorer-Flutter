import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/core/network/movie_api_service.dart';
import 'package:movie_explorer/data/mapper/movie_mappers.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';

/// The default [MovieRepository].
///
/// It maps DTOs to domain models and converts thrown exceptions into
/// [Result]s, so nothing above the data layer needs `try`/`catch`.
@LazySingleton(as: MovieRepository)
class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl(this._api);

  final MovieApiService _api;

  @override
  Future<Result<List<Movie>>> getTrendingMovies() => _guard(() async {
    final dtos = await _api.fetchTrendingMovies();
    return [for (final dto in dtos) dto.toDomain()];
  });

  @override
  Future<Result<List<Movie>>> searchMovies(String query) => _guard(() async {
    final dtos = await _api.searchMovies(query);
    return [for (final dto in dtos) dto.toDomain()];
  });

  @override
  Future<Result<Movie>> getMovieDetails(int id) =>
      _guard(() async => (await _api.fetchMovieDetails(id)).toDomain());

  // Favorites arrive with drift in Phase 3. Until then there are none and
  // toggling is a no-op, but the contract is already in its final shape.

  @override
  Stream<List<Movie>> watchFavoriteMovies() => Stream.value(const []);

  @override
  Stream<Set<int>> watchFavoriteIds() => Stream.value(const {});

  @override
  Future<Result<void>> toggleFavorite(Movie movie) async => const Ok(null);

  /// Runs [action] and turns failures into an [Err]: an [AppException] is
  /// passed through, and any other exception is logged and reported as an
  /// [UnknownException] instead of crashing the screen.
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on AppException catch (exception) {
      return Err(exception);
    } on Exception catch (exception, stackTrace) {
      developer.log(
        'Unexpected repository failure',
        name: 'MovieRepository',
        error: exception,
        stackTrace: stackTrace,
      );
      return const Err(UnknownException());
    }
  }
}
