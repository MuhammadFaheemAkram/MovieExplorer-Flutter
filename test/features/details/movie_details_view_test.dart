import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/features/details/cubit/movie_details_cubit.dart';
import 'package:movie_explorer/features/details/cubit/movie_details_state.dart';
import 'package:movie_explorer/features/details/movie_details_view.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class MockMovieDetailsCubit extends MockCubit<MovieDetailsState>
    implements MovieDetailsCubit {}

void main() {
  late MockMovieDetailsCubit cubit;

  setUp(() {
    cubit = MockMovieDetailsCubit();
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.toggleFavorite()).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester) async {
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<MovieDetailsCubit>.value(
          value: cubit,
          child: const MovieDetailsView(),
        ),
      ),
    );
  }

  testWidgets('loading shows a progress indicator', (tester) async {
    when(() => cubit.state).thenReturn(const MovieDetailsState.loading());

    await pumpView(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error shows the message and "Try again" reloads', (
    tester,
  ) async {
    when(() => cubit.state)
        .thenReturn(const MovieDetailsState.error('Not found.'));

    await pumpView(tester);
    await tester.tap(find.text('Try again'));

    expect(find.text('Not found.'), findsOneWidget);
    verify(() => cubit.load()).called(1);
  });

  testWidgets('loaded shows the movie: facts, genres and overview', (
    tester,
  ) async {
    when(() => cubit.state)
        .thenReturn(const MovieDetailsState.loaded(nebulasEdge));

    await pumpView(tester);

    expect(find.text("Nebula's Edge"), findsOneWidget);
    expect(find.text('2023'), findsOneWidget);
    expect(find.text('8.2'), findsOneWidget);
    expect(find.widgetWithText(GenreChip, 'Science Fiction'), findsOneWidget);
    expect(find.widgetWithText(GenreChip, 'Adventure'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text(nebulasEdge.overview), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('"Add to favorites" toggles the favorite', (tester) async {
    when(() => cubit.state)
        .thenReturn(const MovieDetailsState.loaded(nebulasEdge));

    await pumpView(tester);
    await tester.tap(find.text('Add to favorites'));

    verify(() => cubit.toggleFavorite()).called(1);
  });

  testWidgets('a favorite shows "In favorites"', (tester) async {
    when(() => cubit.state).thenReturn(
      MovieDetailsState.loaded(nebulasEdge.copyWith(isFavorite: true)),
    );

    await pumpView(tester);

    expect(find.text('In favorites'), findsOneWidget);
    expect(find.text('Add to favorites'), findsNothing);
  });
}
