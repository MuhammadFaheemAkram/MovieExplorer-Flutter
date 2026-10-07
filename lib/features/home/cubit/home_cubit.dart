import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/usecase/get_trending_movies_use_case.dart';
import 'package:movie_explorer/features/home/cubit/home_state.dart';

/// Drives the Home screen.
///
/// This is a Cubit, not a Bloc: Home only has plain intents (`load`,
/// `refresh`) and no need for event-stream operators such as debouncing.
/// State is immutable and replaced on every change. The View renders it and
/// calls these methods; it never touches the repository.
@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getTrendingMovies) : super(const HomeState.loading());

  final GetTrendingMoviesUseCase _getTrendingMovies;

  /// First load, and "Try again". Shows the full-screen loading state.
  Future<void> load() async {
    emit(const HomeState.loading());
    final result = await _getTrendingMovies();
    // The screen may have been closed while the request was in flight.
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final movies) => _contentState(movies),
      Err(:final exception) => HomeState.error(exception.message),
    });
  }

  /// Pull-to-refresh. The current movies stay on screen while it runs.
  ///
  /// If it fails while movies are visible, they stay and the failure is
  /// reported once through [HomeLoaded.refreshErrorMessage]. Otherwise the
  /// failure becomes the full error state.
  Future<void> refresh() async {
    final current = state;
    if (current is HomeLoaded && current.refreshErrorMessage != null) {
      // Clear the previous failure, so a repeated failure is reported again.
      emit(current.copyWith(refreshErrorMessage: null));
    }
    final result = await _getTrendingMovies();
    if (isClosed) return;
    switch (result) {
      case Ok(value: final movies):
        emit(_contentState(movies));
      case Err(:final exception):
        final latest = state;
        emit(
          latest is HomeLoaded
              ? latest.copyWith(refreshErrorMessage: exception.message)
              : HomeState.error(exception.message),
        );
    }
  }

  HomeState _contentState(List<Movie> movies) => movies.isEmpty
      ? const HomeState.empty()
      : HomeState.loaded(movies: movies);
}
