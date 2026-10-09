import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/features/search/bloc/search_bloc.dart';
import 'package:movie_explorer/features/search/bloc/search_event.dart';
import 'package:movie_explorer/features/search/bloc/search_state.dart';
import 'package:movie_explorer/features/search/search_view.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

void main() {
  late MockSearchBloc bloc;

  setUpAll(() => registerFallbackValue(const SearchRetried()));

  setUp(() => bloc = MockSearchBloc());

  Future<void> pumpView(
    WidgetTester tester, {
    ValueChanged<Movie>? onMovieTap,
  }) async {
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<SearchBloc>.value(
          value: bloc,
          child: SearchView(onMovieTap: onMovieTap ?? (_) {}),
        ),
      ),
    );
  }

  Matcher queryChanged(String query) =>
      isA<SearchQueryChanged>().having((event) => event.query, 'query', query);

  testWidgets('idle invites the user to search', (tester) async {
    when(() => bloc.state).thenReturn(const SearchState.idle());

    await pumpView(tester);

    expect(find.text('Search movies'), findsOneWidget);
    expect(find.text('Find a movie by its title or genre.'), findsOneWidget);
  });

  testWidgets('typing sends every change to the Bloc', (tester) async {
    when(() => bloc.state).thenReturn(const SearchState.idle());

    await pumpView(tester);
    await tester.enterText(find.byType(TextField), 'dune');

    verify(() => bloc.add(any(that: queryChanged('dune')))).called(1);
  });

  testWidgets('the clear button empties the field and the query', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(const SearchState.idle());
    await pumpView(tester);
    await tester.enterText(find.byType(TextField), 'dune');
    await tester.pump();

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(find.text('dune'), findsNothing);
    verify(() => bloc.add(any(that: queryChanged('')))).called(1);
    expect(find.byTooltip('Clear search'), findsNothing);
  });

  testWidgets('loading shows progress', (tester) async {
    when(() => bloc.state).thenReturn(const SearchState.loading());

    await pumpView(tester);

    expect(find.text('Searching…'), findsOneWidget);
  });

  testWidgets('results show a row per movie and forward taps', (tester) async {
    when(() => bloc.state).thenReturn(const SearchState.results(testMovies));
    final tapped = <Movie>[];

    await pumpView(tester, onMovieTap: tapped.add);
    await tester.tap(find.text('The Silent Harbor'));

    expect(find.byType(MovieRow), findsNWidgets(2));
    expect(tapped, [silentHarbor]);
  });

  testWidgets('no results quotes the query', (tester) async {
    when(() => bloc.state).thenReturn(const SearchState.noResults('zzz'));

    await pumpView(tester);

    expect(find.text('No results'), findsOneWidget);
    expect(find.text('No movies match “zzz”.'), findsOneWidget);
  });

  testWidgets('an error offers "Try again", which retries', (tester) async {
    when(() => bloc.state).thenReturn(const SearchState.error('Offline.'));

    await pumpView(tester);
    await tester.tap(find.text('Try again'));

    expect(find.text('Offline.'), findsOneWidget);
    verify(() => bloc.add(any(that: isA<SearchRetried>()))).called(1);
  });
}
