import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/model/movie_favorites.dart';
import 'package:movie_explorer/domain/usecase/get_movie_details_use_case.dart';
import 'package:movie_explorer/domain/usecase/toggle_favorite_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_favorite_ids_use_case.dart';
import 'package:movie_explorer/features/details/cubit/movie_details_state.dart';

/// Drives the Details screen for one movie.
///
/// The movie id and an optional [preview] are runtime values, not services,
/// so they arrive through injectable's `@factoryParam`:
/// `getIt<MovieDetailsCubit>(param1: id, param2: preview)`.
@injectable
class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  MovieDetailsCubit(
    @factoryParam this.movieId,
    @factoryParam Movie? preview,
    this._getMovieDetails,
    WatchFavoriteIdsUseCase watchFavoriteIds,
    this._toggleFavorite,
  ) : super(
        preview == null
            ? const MovieDetailsState.loading()
            : MovieDetailsState.loaded(preview),
      ) {
    // The heart follows the favorites store, so it stays right even when the
    // movie is (un)favorited from another tab.
    _favoriteIdsSubscription = watchFavoriteIds().listen(_onFavoriteIds);
  }

  final int movieId;
  final GetMovieDetailsUseCase _getMovieDetails;
  final ToggleFavoriteUseCase _toggleFavorite;
  late final StreamSubscription<Set<int>> _favoriteIdsSubscription;
  Set<int> _favoriteIds = const {};

  /// Loads the full details.
  ///
  /// With a preview already on screen this runs quietly: no spinner, and a
  /// failure keeps the preview instead of replacing it with an error page.
  Future<void> load() async {
    final hasContent = state is MovieDetailsLoaded;
    if (!hasContent) emit(const MovieDetailsState.loading());
    final result = await _getMovieDetails(movieId);
    if (isClosed) return;
    switch (result) {
      case Ok(value: final movie):
        emit(MovieDetailsState.loaded(movie.withFavoriteFrom(_favoriteIds)));
      case Err(:final exception) when !hasContent:
        emit(MovieDetailsState.error(exception.message));
      case Err():
        break;
    }
  }

  /// Adds or removes the movie from favorites. The heart updates when the
  /// store emits the new ids.
  Future<void> toggleFavorite() async {
    if (state case MovieDetailsLoaded(:final movie)) {
      await _toggleFavorite(movie);
    }
  }

  void _onFavoriteIds(Set<int> ids) {
    _favoriteIds = ids;
    if (state case MovieDetailsLoaded(:final movie)) {
      final updated = movie.withFavoriteFrom(ids);
      // Only emit on a real change. A Cubit drops a repeated state *except* on
      // its very first emit, and a preview-started screen hasn't emitted yet.
      if (updated != movie) emit(MovieDetailsState.loaded(updated));
    }
  }

  @override
  Future<void> close() async {
    await _favoriteIdsSubscription.cancel();
    return super.close();
  }
}
