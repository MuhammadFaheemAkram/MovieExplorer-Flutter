import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/usecase/get_movie_details_use_case.dart';

import '../../helpers/fakes/fake_movie_repository.dart';
import '../../helpers/fixtures.dart';

void main() {
  group('GetMovieDetailsUseCase', () {
    final getMovieDetails = GetMovieDetailsUseCase(
      FakeMovieRepository(movies: testMovies),
    );

    test('returns the movie with the given id', () async {
      final result = await getMovieDetails(102);

      expect((result as Ok<Movie>).value, silentHarbor);
    });

    test('returns NotFoundException for an unknown id', () async {
      final result = await getMovieDetails(999);

      expect((result as Err<Movie>).exception, isA<NotFoundException>());
    });
  });
}
