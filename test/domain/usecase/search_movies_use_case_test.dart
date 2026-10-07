import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/usecase/search_movies_use_case.dart';

import '../../helpers/fakes/fake_movie_repository.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeMovieRepository repository;
  late SearchMoviesUseCase searchMovies;

  setUp(() {
    repository = FakeMovieRepository(movies: testMovies);
    searchMovies = SearchMoviesUseCase(repository);
  });

  List<Movie> moviesOf(Result<List<Movie>> result) =>
      (result as Ok<List<Movie>>).value;

  group('SearchMoviesUseCase', () {
    test('returns the matching movies', () async {
      final result = await searchMovies('harbor');

      expect(moviesOf(result), [silentHarbor]);
    });

    test('trims the query before searching', () async {
      await searchMovies('  edge  ');

      expect(repository.searchQueries, ['edge']);
    });

    test('a blank query returns no movies and skips the repository', () async {
      final result = await searchMovies('   ');

      expect(moviesOf(result), isEmpty);
      expect(repository.searchQueries, isEmpty);
    });
  });
}
