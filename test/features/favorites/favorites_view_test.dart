import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/features/favorites/cubit/favorites_cubit.dart';
import 'package:movie_explorer/features/favorites/cubit/favorites_state.dart';
import 'package:movie_explorer/features/favorites/favorites_view.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class MockFavoritesCubit extends MockCubit<FavoritesState>
    implements FavoritesCubit {}

void main() {
  late MockFavoritesCubit cubit;

  final favoriteNebula = nebulasEdge.copyWith(isFavorite: true);
  final favoriteHarbor = silentHarbor.copyWith(isFavorite: true);

  setUpAll(() => registerFallbackValue(nebulasEdge));

  setUp(() {
    cubit = MockFavoritesCubit();
    when(() => cubit.remove(any())).thenAnswer((_) async {});
  });

  Future<void> pumpView(
    WidgetTester tester, {
    ValueChanged<Movie>? onMovieTap,
  }) async {
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<FavoritesCubit>.value(
          value: cubit,
          child: FavoritesView(onMovieTap: onMovieTap ?? (_) {}),
        ),
      ),
    );
  }

  testWidgets('empty explains that favorites work offline', (tester) async {
    when(() => cubit.state).thenReturn(const FavoritesState.empty());

    await pumpView(tester);

    expect(find.text('No favorites yet'), findsOneWidget);
    expect(
      find.text('Movies you favorite appear here and stay available offline.'),
      findsOneWidget,
    );
  });

  testWidgets('loaded shows a row per favorite and forwards taps', (
    tester,
  ) async {
    when(() => cubit.state)
        .thenReturn(FavoritesState.loaded([favoriteHarbor, favoriteNebula]));
    final tapped = <Movie>[];

    await pumpView(tester, onMovieTap: tapped.add);
    await tester.tap(find.text("Nebula's Edge"));

    expect(find.byType(MovieRow), findsNWidgets(2));
    expect(tapped, [favoriteNebula]);
  });

  testWidgets('tapping the filled heart removes the favorite', (tester) async {
    when(() => cubit.state).thenReturn(FavoritesState.loaded([favoriteNebula]));

    await pumpView(tester);
    await tester.tap(find.byTooltip('Remove from favorites'));

    verify(() => cubit.remove(favoriteNebula)).called(1);
  });

  testWidgets('swiping a row away removes the favorite', (tester) async {
    // Like the real Cubit, the mock drops the row as soon as it is removed: a
    // dismissed Dismissible must not be rebuilt into the list again.
    final states = StreamController<FavoritesState>();
    addTearDown(states.close);
    whenListen(
      cubit,
      states.stream,
      initialState: FavoritesState.loaded([favoriteNebula, favoriteHarbor]),
    );
    when(() => cubit.remove(any())).thenAnswer((invocation) async {
      states.add(FavoritesState.loaded([favoriteHarbor]));
    });

    await pumpView(tester);
    await tester.drag(find.text("Nebula's Edge"), const Offset(-600, 0));
    await tester.pumpAndSettle();

    verify(() => cubit.remove(favoriteNebula)).called(1);
    expect(find.text("Nebula's Edge"), findsNothing);
    expect(find.text('The Silent Harbor'), findsOneWidget);
  });
}
