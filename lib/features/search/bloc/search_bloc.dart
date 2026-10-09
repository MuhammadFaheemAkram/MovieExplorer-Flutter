import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/usecase/search_movies_use_case.dart';
import 'package:movie_explorer/features/search/bloc/search_event.dart';
import 'package:movie_explorer/features/search/bloc/search_state.dart';
import 'package:movie_explorer/features/search/bloc/search_transformers.dart';

/// Drives the Search screen.
///
/// It is a **Bloc**, not a Cubit, because typing is a *stream* of events that
/// needs shaping: debounced, with stale searches cancelled. Event transformers
/// express that declaratively (see [debounceRestartable]), which a Cubit's
/// plain methods can't do without hand-written timers.
@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
    this._searchMovies, {
    @ignoreParam Duration debounce = const Duration(milliseconds: 300),
  }) : super(const SearchState.idle()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounceRestartable(debounce),
    );
    on<SearchRetried>(_onRetried, transformer: droppable());
  }

  final SearchMoviesUseCase _searchMovies;

  /// The last query actually searched (trimmed), for dedupe and retry.
  String _lastQuery = '';

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      _lastQuery = '';
      emit(const SearchState.idle());
      return;
    }
    // Skip a repeat of the query whose results are already on screen (e.g.
    // "dune" → "dun" → "dune" within the debounce window). An in-flight or
    // failed search must run again: restartable has just cancelled it.
    final alreadyShown =
        query == _lastQuery &&
        switch (state) {
          SearchResults() || SearchNoResults() => true,
          _ => false,
        };
    if (alreadyShown) return;
    await _search(query, emit);
  }

  Future<void> _onRetried(SearchRetried event, Emitter<SearchState> emit) {
    return _lastQuery.isEmpty ? Future.value() : _search(_lastQuery, emit);
  }

  Future<void> _search(String query, Emitter<SearchState> emit) async {
    _lastQuery = query;
    emit(const SearchState.loading());
    final result = await _searchMovies(query);
    // If a newer query restarted this handler, `emit` is now a no-op.
    emit(switch (result) {
      Ok(value: final movies) when movies.isEmpty => SearchState.noResults(
        query,
      ),
      Ok(value: final movies) => SearchState.results(movies),
      Err(:final exception) => SearchState.error(exception.message),
    });
  }
}
