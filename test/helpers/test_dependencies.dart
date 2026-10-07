import 'package:movie_explorer/di/injection.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';
import 'package:movie_explorer/domain/usecase/get_trending_movies_use_case.dart';
import 'package:movie_explorer/features/home/cubit/home_cubit.dart';

/// Registers what the app's Pages resolve from `getIt`, backed by
/// [movieRepository]. App-level widget tests then never touch assets, latency
/// or the network.
///
/// Pair it with `tearDown(getIt.reset)`, so each test starts from a clean
/// container.
void registerTestDependencies({required MovieRepository movieRepository}) {
  getIt
    ..registerFactory(() => GetTrendingMoviesUseCase(movieRepository))
    ..registerFactory(() => HomeCubit(getIt()));
}
