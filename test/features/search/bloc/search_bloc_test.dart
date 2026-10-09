import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/domain/usecase/search_movies_use_case.dart';
import 'package:movie_explorer/features/search/bloc/search_bloc.dart';
import 'package:movie_explorer/features/search/bloc/search_event.dart';
import 'package:movie_explorer/features/search/bloc/search_state.dart';

import '../../../helpers/fakes/fake_movie_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeMovieRepository repository;

  setUp(() => repository = FakeMovieRepository(movies: testMovies));
  tearDown(() => repository.dispose());

  // A short debounce keeps the suite fast. Waits are a few debounces long.
  const debounce = Duration(milliseconds: 10);
  const settle = Duration(milliseconds: 40);
  Future<void> pause() => Future<void>.delayed(settle);

  SearchBloc buildBloc() =>
      SearchBloc(SearchMoviesUseCase(repository), debounce: debounce);

  test('starts idle', () async {
    final bloc = buildBloc();
    addTearDown(bloc.close);

    expect(bloc.state, const SearchState.idle());
  });

  blocTest<SearchBloc, SearchState>(
    'a matching query debounces to results',
    build: buildBloc,
    act: (bloc) => bloc.add(const SearchQueryChanged('harbor')),
    wait: settle,
    expect: () => [
      const SearchState.loading(),
      const SearchState.results([silentHarbor]),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'a query without matches ends in noResults',
    build: buildBloc,
    act: (bloc) => bloc.add(const SearchQueryChanged('zzz')),
    wait: settle,
    expect: () => [
      const SearchState.loading(),
      const SearchState.noResults('zzz'),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'rapid typing runs a single search for the last query',
    build: buildBloc,
    act: (bloc) => bloc
      ..add(const SearchQueryChanged('n'))
      ..add(const SearchQueryChanged('ne'))
      ..add(const SearchQueryChanged('nebula ')),
    wait: settle,
    expect: () => [
      const SearchState.loading(),
      const SearchState.results([nebulasEdge]),
    ],
    verify: (_) => expect(repository.searchQueries, ['nebula']),
  );

  blocTest<SearchBloc, SearchState>(
    'a blank query goes idle immediately and drops the pending search',
    build: buildBloc,
    seed: () => const SearchState.results([nebulasEdge]),
    act: (bloc) => bloc
      ..add(const SearchQueryChanged('harbor'))
      ..add(const SearchQueryChanged('   ')),
    wait: settle,
    expect: () => [const SearchState.idle()],
    verify: (_) => expect(repository.searchQueries, isEmpty),
  );

  blocTest<SearchBloc, SearchState>(
    'a failure shows the error, and retry re-runs the last query',
    setUp: () => repository.failure = const NetworkException(),
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const SearchQueryChanged('harbor'));
      await pause();
      repository.failure = null;
      bloc.add(const SearchRetried());
    },
    wait: settle,
    expect: () => [
      const SearchState.loading(),
      SearchState.error(const NetworkException().message),
      const SearchState.loading(),
      const SearchState.results([silentHarbor]),
    ],
    verify: (_) => expect(repository.searchQueries, ['harbor', 'harbor']),
  );

  blocTest<SearchBloc, SearchState>(
    'a newer query cancels the in-flight search (restartable)',
    build: buildBloc,
    act: (bloc) async {
      repository.gate = Completer<void>();
      bloc.add(const SearchQueryChanged('nebula'));
      await pause(); // "nebula" is now in flight, blocked on the gate.
      bloc.add(const SearchQueryChanged('harbor'));
      await pause();
      repository.gate!.complete();
    },
    wait: settle,
    // "nebula" never shows results: its handler was cancelled.
    expect: () => [
      const SearchState.loading(),
      const SearchState.results([silentHarbor]),
    ],
    verify: (_) => expect(repository.searchQueries, ['nebula', 'harbor']),
  );

  blocTest<SearchBloc, SearchState>(
    'the query already on screen is not searched again',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const SearchQueryChanged('harbor'));
      await pause();
      bloc
        ..add(const SearchQueryChanged('harbo'))
        ..add(const SearchQueryChanged('harbor'));
    },
    wait: settle,
    expect: () => [
      const SearchState.loading(),
      const SearchState.results([silentHarbor]),
    ],
    verify: (_) => expect(repository.searchQueries, ['harbor']),
  );

  blocTest<SearchBloc, SearchState>(
    're-typing the query that is still in flight searches again instead of '
    'staying stuck on loading',
    build: buildBloc,
    act: (bloc) async {
      repository.gate = Completer<void>();
      bloc.add(const SearchQueryChanged('harbor'));
      await pause(); // In flight; restartable will cancel it next.
      bloc
        ..add(const SearchQueryChanged('harbo'))
        ..add(const SearchQueryChanged('harbor'));
      await pause();
      repository.gate!.complete();
    },
    wait: settle,
    expect: () => [
      const SearchState.loading(),
      const SearchState.results([silentHarbor]),
    ],
    verify: (_) => expect(repository.searchQueries, ['harbor', 'harbor']),
  );
}
