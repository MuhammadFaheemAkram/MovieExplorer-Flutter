import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/usecase/toggle_favorite_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_favorite_movies_use_case.dart';
import 'package:movie_explorer/features/favorites/cubit/favorites_state.dart';

/// Drives the Favorites screen by rendering whatever the drift store emits.
///
/// The Cubit keeps no list of its own beyond the last snapshot, so drift stays
/// the single source of truth: a favorite added on Home appears here with no
/// extra code.
@injectable
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(
    WatchFavoriteMoviesUseCase watchFavoriteMovies,
    this._toggleFavorite,
  ) : super(const FavoritesState.loading()) {
    _subscription = watchFavoriteMovies().listen((movies) {
      _stored = movies;
      emit(_stateFor(movies));
    });
  }

  final ToggleFavoriteUseCase _toggleFavorite;
  late final StreamSubscription<List<Movie>> _subscription;
  List<Movie> _stored = const [];

  /// Removes [movie] from favorites.
  ///
  /// The row disappears *immediately* (an optimistic update). A dismissed
  /// `Dismissible` throws if the list rebuilds while it is still in it, and the
  /// drift stream only confirms a moment later. Removing it from state right
  /// away closes that gap. If the write fails, the last stored list is shown
  /// again.
  Future<void> remove(Movie movie) async {
    final current = state;
    if (current is! FavoritesLoaded) return;
    emit(
      _stateFor([
        for (final m in current.movies)
          if (m.id != movie.id) m,
      ]),
    );

    // A listed movie is always a favorite, so toggling removes it.
    final result = await _toggleFavorite(movie);
    if (result is Err<void> && !isClosed) emit(_stateFor(_stored));
  }

  FavoritesState _stateFor(List<Movie> movies) => movies.isEmpty
      ? const FavoritesState.empty()
      : FavoritesState.loaded(movies);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
