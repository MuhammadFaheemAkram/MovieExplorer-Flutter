import 'package:movie_explorer/domain/model/movie.dart';

// Favorite state lives in the favorites store, not in network data. Screens
// receive the favorite ids as a stream and overlay them with these helpers, so
// every heart in the app reflects the same single source of truth.

extension MovieFavorites on Movie {
  /// This movie with `isFavorite` taken from [favoriteIds].
  Movie withFavoriteFrom(Set<int> favoriteIds) =>
      copyWith(isFavorite: favoriteIds.contains(id));
}

extension MovieListFavorites on List<Movie> {
  /// These movies with `isFavorite` taken from [favoriteIds].
  List<Movie> withFavoritesFrom(Set<int> favoriteIds) => [
    for (final movie in this) movie.withFavoriteFrom(favoriteIds),
  ];
}
