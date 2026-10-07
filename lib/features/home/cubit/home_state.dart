import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movie_explorer/domain/model/movie.dart';

part 'home_state.freezed.dart';

/// Everything the Home screen can show.
///
/// As a sealed union, impossible combinations (for example "loading" *and*
/// "error" at once) can't be represented, and the View's exhaustive `switch`
/// must handle every case.
@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState.loading() = HomeLoading;

  const factory HomeState.empty() = HomeEmpty;

  const factory HomeState.loaded({
    required List<Movie> movies,

    /// Set when a pull-to-refresh fails while movies are on screen. The View
    /// shows it once as a SnackBar; it is cleared when the next refresh starts.
    String? refreshErrorMessage,
  }) = HomeLoaded;

  const factory HomeState.error(String message) = HomeError;
}
