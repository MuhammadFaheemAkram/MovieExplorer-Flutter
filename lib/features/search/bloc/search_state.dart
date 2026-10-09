import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movie_explorer/domain/model/movie.dart';

part 'search_state.freezed.dart';

/// The full lifecycle of a debounced search: nothing typed yet, in flight,
/// results, a completed search with no matches, and failure.
@freezed
sealed class SearchState with _$SearchState {
  const factory SearchState.idle() = SearchIdle;

  const factory SearchState.loading() = SearchLoading;

  const factory SearchState.results(List<Movie> movies) = SearchResults;

  const factory SearchState.noResults(String query) = SearchNoResults;

  const factory SearchState.error(String message) = SearchError;
}
