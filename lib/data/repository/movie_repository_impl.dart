import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/core/database/daos/favorites_dao.dart';
import 'package:movie_explorer/core/network/movie_api_service.dart';
import 'package:movie_explorer/data/mapper/favorite_movie_mappers.dart';
import 'package:movie_explorer/data/mapper/movie_mappers.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';

/// The default [MovieRepository].
///
/// It combines two data sources behind one contract: the (fake) network, for
/// browsing, and the drift favorites store, the single source of truth for
/// what is favorited. It maps every model to the domain type and converts
/// thrown exceptions into [Result]s, so nothing above the data layer needs
/// `try`/`catch`.
@LazySingleton(as: MovieRepository)
class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl(this._api, this._favorites);

  final MovieApiService _api;
  final FavoritesDao _favorites;

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

  /// Details come from the API. If that fails but the movie is a favorite, the
  /// copy stored in drift is returned instead, so favorites work fully offline.
  @override
  Future<Result<Movie>> getMovieDetails(int id) async {
    final remote = await _guard(
      () async => (await _api.fetchMovieDetails(id)).toDomain(),
    );
    if (remote is Ok<Movie>) return remote;
    final stored = await _guard(() => _favorites.findById(id));
    return switch (stored) {
      Ok(value: final row?) => Ok(row.toDomain()),
      _ => remote,
    };
  }

  @override
  Stream<List<Movie>> watchFavoriteMovies() => _favorites.watchAll().map(
    (rows) => [for (final row in rows) row.toDomain()],
  );

  @override
  Stream<Set<int>> watchFavoriteIds() => _favorites.watchIds();

  @override
  Future<Result<void>> toggleFavorite(Movie movie) => _guard(() async {
    // UTC keeps the stored ISO-8601 timestamps sortable as text.
    final row = movie.toFavoriteCompanion(addedAt: DateTime.now().toUtc());
    await _favorites.toggle(row);
  });

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
