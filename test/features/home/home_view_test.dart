import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/features/home/cubit/home_cubit.dart';
import 'package:movie_explorer/features/home/cubit/home_state.dart';
import 'package:movie_explorer/features/home/home_view.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  late MockHomeCubit cubit;

  setUp(() {
    cubit = MockHomeCubit();
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
  });

  Future<void> pumpView(
    WidgetTester tester, {
    ValueChanged<Movie>? onMovieTap,
  }) async {
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<HomeCubit>.value(
          value: cubit,
          child: HomeView(onMovieTap: onMovieTap ?? (_) {}),
        ),
      ),
    );
  }

  testWidgets('loading shows a progress indicator and message', (tester) async {
    when(() => cubit.state).thenReturn(const HomeState.loading());

    await pumpView(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading trending movies…'), findsOneWidget);
  });

  testWidgets('loaded shows a card per movie and forwards taps', (
    tester,
  ) async {
    when(() => cubit.state)
        .thenReturn(const HomeState.loaded(movies: testMovies));
    final tapped = <Movie>[];

    await pumpView(tester, onMovieTap: tapped.add);
    await tester.tap(find.text('The Silent Harbor'));

    expect(find.byType(MovieCard), findsNWidgets(2));
    expect(find.text("Nebula's Edge"), findsOneWidget);
    expect(tapped, [silentHarbor]);
  });

  testWidgets('error shows the message and "Try again" reloads', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(const HomeState.error('Network down.'));

    await pumpView(tester);
    await tester.tap(find.text('Try again'));

    expect(find.text('Network down.'), findsOneWidget);
    verify(() => cubit.load()).called(1);
  });

  testWidgets('empty offers a Refresh action that reloads', (tester) async {
    when(() => cubit.state).thenReturn(const HomeState.empty());

    await pumpView(tester);
    await tester.tap(find.text('Refresh'));

    expect(find.text('No movies'), findsOneWidget);
    verify(() => cubit.load()).called(1);
  });

  testWidgets('pulling down the grid refreshes', (tester) async {
    when(() => cubit.state)
        .thenReturn(const HomeState.loaded(movies: testMovies));

    await pumpView(tester);
    await tester.fling(find.byType(GridView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => cubit.refresh()).called(1);
  });

  testWidgets('a failed refresh shows a SnackBar and keeps the movies', (
    tester,
  ) async {
    whenListen(
      cubit,
      Stream.value(
        const HomeState.loaded(
          movies: testMovies,
          refreshErrorMessage: 'Could not refresh.',
        ),
      ),
      initialState: const HomeState.loaded(movies: testMovies),
    );

    await pumpView(tester);
    await tester.pump();

    expect(find.widgetWithText(SnackBar, 'Could not refresh.'), findsOneWidget);
    expect(find.byType(MovieCard), findsNWidgets(2));
  });
}
