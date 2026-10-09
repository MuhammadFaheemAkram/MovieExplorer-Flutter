import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movie_explorer/domain/model/movie.dart';

part 'favorites_state.freezed.dart';

/// What the Favorites screen can show.
///
/// There is no error case: favorites come from the local database, so the
/// screen is either still reading its first snapshot, empty, or showing movies.
/// It works fully offline.
@freezed
sealed class FavoritesState with _$FavoritesState {
  const factory FavoritesState.loading() = FavoritesLoading;

  const factory FavoritesState.empty() = FavoritesEmpty;

  const factory FavoritesState.loaded(List<Movie> movies) = FavoritesLoaded;
}
