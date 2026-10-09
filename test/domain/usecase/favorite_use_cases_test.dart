import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/usecase/toggle_favorite_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_favorite_ids_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_favorite_movies_use_case.dart';

import '../../helpers/fakes/fake_movie_repository.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeMovieRepository repository;

  setUp(() => repository = FakeMovieRepository());
  tearDown(() => repository.dispose());

  group('ToggleFavoriteUseCase', () {
    test('adds a movie, then removes it on a second toggle', () async {
      final toggleFavorite = ToggleFavoriteUseCase(repository);
      final watchIds = WatchFavoriteIdsUseCase(repository);

      await toggleFavorite(nebulasEdge);
      expect(await watchIds().first, {101});

      await toggleFavorite(nebulasEdge);
      expect(await watchIds().first, isEmpty);
    });

    test('propagates a failed write', () async {
      repository.toggleFailure = const DataFormatException();

      final result = await ToggleFavoriteUseCase(repository)(nebulasEdge);

      expect(result, isA<Err<void>>());
    });
  });

  group('WatchFavoriteMoviesUseCase', () {
    test('streams the stored favorites, newest first', () async {
      final repository = FakeMovieRepository(favorites: testMovies);
      addTearDown(repository.dispose);

      final favorites = await WatchFavoriteMoviesUseCase(repository)().first;

      expect(favorites.map((movie) => movie.id), [102, 101]);
      expect(favorites.every((movie) => movie.isFavorite), isTrue);
    });
  });
}
