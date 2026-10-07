import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/data/repository/movie_repository_impl.dart';
import 'package:movie_explorer/domain/model/movie.dart';

import '../../helpers/fakes/stub_movie_api_service.dart';
import '../../helpers/fixtures.dart';

void main() {
  late StubMovieApiService api;
  late MovieRepositoryImpl repository;

  setUp(() {
    api = StubMovieApiService(movies: [nebulasEdgeDto, silentHarborDto]);
    repository = MovieRepositoryImpl(api);
  });

  /// Unwraps an [Ok] or fails the test with the unexpected [Err].
  T okValue<T>(Result<T> result) => switch (result) {
    Ok(:final value) => value,
    Err(:final exception) => fail('Expected Ok, got Err($exception)'),
  };

  /// Unwraps an [Err] or fails the test with the unexpected [Ok].
  AppException errException<T>(Result<T> result) => switch (result) {
    Ok(:final value) => fail('Expected Err, got Ok($value)'),
    Err(:final exception) => exception,
  };

  group('MovieRepositoryImpl', () {
    test('getTrendingMovies maps DTOs to domain movies', () async {
      final movies = okValue(await repository.getTrendingMovies());

      expect(movies.map((movie) => movie.title), [
        "Nebula's Edge",
        'The Silent Harbor',
      ]);
      expect(movies.first.releaseYear, '2023');
      expect(movies.every((movie) => !movie.isFavorite), isTrue);
    });

    test('searchMovies maps DTOs to domain movies', () async {
      final movies = okValue(await repository.searchMovies('edge'));

      expect(movies, everyElement(isA<Movie>()));
      expect(movies, hasLength(2));
    });

    test('getMovieDetails returns the mapped movie', () async {
      final movie = okValue(await repository.getMovieDetails(102));

      expect(movie.title, 'The Silent Harbor');
    });

    test('an AppException from the API becomes an Err', () async {
      api.error = const NetworkException();

      final exception = errException(await repository.getTrendingMovies());

      expect(exception, isA<NetworkException>());
    });

    test('an unknown id becomes an Err with NotFoundException', () async {
      final exception = errException(await repository.getMovieDetails(999));

      expect(exception, isA<NotFoundException>());
    });

    test('any other exception becomes an UnknownException', () async {
      api.error = const FormatException('unexpected');

      final exception = errException(await repository.searchMovies('x'));

      expect(exception, isA<UnknownException>());
    });

    test('favorites are empty until the drift store arrives', () async {
      expect(await repository.watchFavoriteMovies().first, isEmpty);
      expect(await repository.watchFavoriteIds().first, isEmpty);
      expect(await repository.toggleFavorite(nebulasEdge), isA<Ok<void>>());
    });
  });
}
