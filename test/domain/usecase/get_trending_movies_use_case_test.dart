import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/usecase/get_trending_movies_use_case.dart';

import '../../helpers/fakes/fake_movie_repository.dart';
import '../../helpers/fixtures.dart';

void main() {
  group('GetTrendingMoviesUseCase', () {
    test("returns the repository's movies", () async {
      final repository = FakeMovieRepository(movies: testMovies);

      final result = await GetTrendingMoviesUseCase(repository)();

      expect((result as Ok<List<Movie>>).value, testMovies);
    });

    test('propagates repository failures', () async {
      final repository = FakeMovieRepository(failure: const NetworkException());

      final result = await GetTrendingMoviesUseCase(repository)();

      expect(
        result,
        isA<Err<List<Movie>>>().having(
          (err) => err.exception,
          'exception',
          isA<NetworkException>(),
        ),
      );
    });
  });
}
