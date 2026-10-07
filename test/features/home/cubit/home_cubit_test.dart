import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/domain/usecase/get_trending_movies_use_case.dart';
import 'package:movie_explorer/features/home/cubit/home_cubit.dart';
import 'package:movie_explorer/features/home/cubit/home_state.dart';

import '../../../helpers/fakes/fake_movie_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeMovieRepository repository;

  setUp(() => repository = FakeMovieRepository(movies: testMovies));

  HomeCubit buildCubit() => HomeCubit(GetTrendingMoviesUseCase(repository));

  final networkMessage = const NetworkException().message;

  test('starts in the loading state', () {
    expect(buildCubit().state, const HomeState.loading());
  });

  group('load', () {
    blocTest<HomeCubit, HomeState>(
      'emits [loading, loaded] when movies arrive',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeState.loading(),
        const HomeState.loaded(movies: testMovies),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [loading, empty] when there are no movies',
      setUp: () => repository.movies = const [],
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [const HomeState.loading(), const HomeState.empty()],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [loading, error] with the failure message',
      setUp: () => repository.failure = const NetworkException(),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeState.loading(),
        HomeState.error(networkMessage),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      '"Try again" after an error goes back through loading',
      build: buildCubit,
      seed: () => HomeState.error(networkMessage),
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeState.loading(),
        const HomeState.loaded(movies: testMovies),
      ],
    );

    test('does not emit after the Cubit is closed mid-request', () async {
      repository.gate = Completer<void>();
      final cubit = buildCubit();

      final loading = cubit.load();
      await cubit.close();
      repository.gate!.complete();

      // Emitting on a closed Cubit would throw a StateError here.
      await expectLater(loading, completes);
    });
  });

  group('refresh', () {
    blocTest<HomeCubit, HomeState>(
      'replaces the movies on success, without a loading state',
      build: buildCubit,
      seed: () => const HomeState.loaded(movies: [nebulasEdge]),
      act: (cubit) => cubit.refresh(),
      expect: () => [const HomeState.loaded(movies: testMovies)],
    );

    blocTest<HomeCubit, HomeState>(
      'keeps the movies and reports the failure when it fails',
      setUp: () => repository.failure = const NetworkException(),
      build: buildCubit,
      seed: () => const HomeState.loaded(movies: testMovies),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        HomeState.loaded(
          movies: testMovies,
          refreshErrorMessage: networkMessage,
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'clears a previous failure first, so a repeated failure is reported '
      'again',
      setUp: () => repository.failure = const NetworkException(),
      build: buildCubit,
      seed: () => HomeState.loaded(
        movies: testMovies,
        refreshErrorMessage: networkMessage,
      ),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const HomeState.loaded(movies: testMovies),
        HomeState.loaded(
          movies: testMovies,
          refreshErrorMessage: networkMessage,
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'becomes the error state when no movies are on screen',
      setUp: () => repository.failure = const DataFormatException(),
      build: buildCubit,
      seed: () => HomeState.error(networkMessage),
      act: (cubit) => cubit.refresh(),
      expect: () => [HomeState.error(const DataFormatException().message)],
    );

    blocTest<HomeCubit, HomeState>(
      'shows the empty state when the refreshed list is empty',
      setUp: () => repository.movies = const [],
      build: buildCubit,
      seed: () => const HomeState.loaded(movies: testMovies),
      act: (cubit) => cubit.refresh(),
      expect: () => [const HomeState.empty()],
    );
  });
}
