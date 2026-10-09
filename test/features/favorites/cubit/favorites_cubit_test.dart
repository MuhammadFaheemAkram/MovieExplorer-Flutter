import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/domain/usecase/toggle_favorite_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_favorite_movies_use_case.dart';
import 'package:movie_explorer/features/favorites/cubit/favorites_cubit.dart';
import 'package:movie_explorer/features/favorites/cubit/favorites_state.dart';

import '../../../helpers/fakes/fake_movie_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeMovieRepository repository;

  setUp(() => repository = FakeMovieRepository());
  tearDown(() => repository.dispose());

  FavoritesCubit buildCubit() => FavoritesCubit(
    WatchFavoriteMoviesUseCase(repository),
    ToggleFavoriteUseCase(repository),
  );

  final favoriteNebula = nebulasEdge.copyWith(isFavorite: true);
  final favoriteHarbor = silentHarbor.copyWith(isFavorite: true);

  /// Lets the store's first emission arrive before acting.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  blocTest<FavoritesCubit, FavoritesState>(
    'shows the empty state when there are no favorites',
    build: buildCubit,
    expect: () => [const FavoritesState.empty()],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'lists the stored favorites, newest first',
    setUp: () => repository = FakeMovieRepository(favorites: testMovies),
    build: buildCubit,
    expect: () => [
      FavoritesState.loaded([favoriteHarbor, favoriteNebula]),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'shows a favorite added on another screen',
    build: buildCubit,
    act: (_) async {
      await settle();
      await repository.toggleFavorite(nebulasEdge);
    },
    expect: () => [
      const FavoritesState.empty(),
      FavoritesState.loaded([favoriteNebula]),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'remove hides the row immediately, then the store confirms it',
    setUp: () => repository = FakeMovieRepository(favorites: testMovies),
    build: buildCubit,
    act: (cubit) async {
      await settle();
      await cubit.remove(favoriteHarbor);
    },
    // The store's confirmation equals the optimistic state, so no third
    // state is emitted.
    expect: () => [
      FavoritesState.loaded([favoriteHarbor, favoriteNebula]),
      FavoritesState.loaded([favoriteNebula]),
    ],
    verify: (_) => expect(repository.favoriteMovies, [favoriteNebula]),
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'removing the last favorite shows the empty state',
    setUp: () => repository = FakeMovieRepository(favorites: [nebulasEdge]),
    build: buildCubit,
    act: (cubit) async {
      await settle();
      await cubit.remove(favoriteNebula);
    },
    expect: () => [
      FavoritesState.loaded([favoriteNebula]),
      const FavoritesState.empty(),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'restores the row when the write fails',
    setUp: () {
      repository = FakeMovieRepository(favorites: testMovies)
        ..toggleFailure = const DataFormatException();
    },
    build: buildCubit,
    act: (cubit) async {
      await settle();
      await cubit.remove(favoriteHarbor);
    },
    expect: () => [
      FavoritesState.loaded([favoriteHarbor, favoriteNebula]),
      FavoritesState.loaded([favoriteNebula]),
      FavoritesState.loaded([favoriteHarbor, favoriteNebula]),
    ],
  );
}
