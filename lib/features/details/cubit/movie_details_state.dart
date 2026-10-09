import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movie_explorer/domain/model/movie.dart';

part 'movie_details_state.freezed.dart';

/// What the Details screen can show.
@freezed
sealed class MovieDetailsState with _$MovieDetailsState {
  const factory MovieDetailsState.loading() = MovieDetailsLoading;

  const factory MovieDetailsState.loaded(Movie movie) = MovieDetailsLoaded;

  const factory MovieDetailsState.error(String message) = MovieDetailsError;
}
