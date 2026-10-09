import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/usecase/get_movie_details_use_case.dart';
import 'package:movie_explorer/domain/usecase/toggle_favorite_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_favorite_ids_use_case.dart';
import 'package:movie_explorer/features/details/cubit/movie_details_cubit.dart';
import 'package:movie_explorer/features/details/cubit/movie_details_state.dart';

import '../../../helpers/fakes/fake_movie_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeMovieRepository repository;

  setUp(() => repository = FakeMovieRepository(movies: testMovies));
  tearDown(() => repository.dispose());

  MovieDetailsCubit buildCubit({int movieId = 102, Movie? preview}) =>
      MovieDetailsCubit(
        movieId,
        preview,
        GetMovieDetailsUseCase(repository),
        WatchFavoriteIdsUseCase(repository),
        ToggleFavoriteUseCase(repository),
      );

  // A list's copy of the movie, slightly different from the full details.
  final harborPreview = silentHarbor.copyWith(overview: 'Preview overview');

  group('without a preview (e.g. a deep link)', () {
    test('starts in the loading state', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state, const MovieDetailsState.loading());
    });

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'emits [loading, loaded] with the details',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const MovieDetailsState.loading(),
        const MovieDetailsState.loaded(silentHarbor),
      ],
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'emits [loading, error] when the movie cannot be loaded',
      build: () => buildCubit(movieId: 999),
      act: (cubit) => cubit.load(),
      expect: () => [
        const MovieDetailsState.loading(),
        MovieDetailsState.error(const NotFoundException().message),
      ],
    );
  });

  group('with a preview (opened from a list)', () {
    test('starts with the preview, so the screen and Hero are ready', () async {
      final cubit = buildCubit(preview: harborPreview);
      addTearDown(cubit.close);

      expect(cubit.state, MovieDetailsState.loaded(harborPreview));
    });

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'refreshes quietly to the full details, without a loading state',
      build: () => buildCubit(preview: harborPreview),
      act: (cubit) => cubit.load(),
      expect: () => [const MovieDetailsState.loaded(silentHarbor)],
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'keeps the preview when the refresh fails',
      setUp: () => repository.failure = const NetworkException(),
      build: () => buildCubit(preview: harborPreview),
      act: (cubit) => cubit.load(),
      expect: () => <MovieDetailsState>[],
    );
  });

  group('favorites', () {
    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'the heart follows the store, even when changed on another screen',
      build: () => buildCubit(preview: silentHarbor),
      act: (_) => repository.toggleFavorite(silentHarbor),
      expect: () => [
        MovieDetailsState.loaded(silentHarbor.copyWith(isFavorite: true)),
      ],
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'toggleFavorite writes through the repository',
      build: () => buildCubit(preview: silentHarbor),
      act: (cubit) => cubit.toggleFavorite(),
      expect: () => [
        MovieDetailsState.loaded(silentHarbor.copyWith(isFavorite: true)),
      ],
      verify: (_) => expect(repository.toggledIds, [102]),
    );

    blocTest<MovieDetailsCubit, MovieDetailsState>(
      'toggleFavorite does nothing while loading',
      build: buildCubit,
      act: (cubit) => cubit.toggleFavorite(),
      expect: () => <MovieDetailsState>[],
      verify: (_) => expect(repository.toggledIds, isEmpty),
    );
  });
}
