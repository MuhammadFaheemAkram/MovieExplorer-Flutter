import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/domain/model/movie_favorites.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('favorite overlay', () {
    test('marks a movie whose id is in the set', () {
      expect(nebulasEdge.withFavoriteFrom({101}).isFavorite, isTrue);
    });

    test('clears the flag when the id is no longer in the set', () {
      final favorite = nebulasEdge.copyWith(isFavorite: true);

      expect(favorite.withFavoriteFrom({}).isFavorite, isFalse);
    });

    test('overlays a whole list and keeps its order', () {
      final movies = testMovies.withFavoritesFrom({102});

      expect(movies.map((movie) => movie.id), [101, 102]);
      expect(movies.map((movie) => movie.isFavorite), [false, true]);
    });
  });
}
