import 'package:movie_explorer/di/injection.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';
import 'package:movie_explorer/domain/usecase/get_movie_details_use_case.dart';
import 'package:movie_explorer/domain/usecase/get_trending_movies_use_case.dart';
import 'package:movie_explorer/domain/usecase/toggle_favorite_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_favorite_ids_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_favorite_movies_use_case.dart';
import 'package:movie_explorer/features/details/cubit/movie_details_cubit.dart';
import 'package:movie_explorer/features/favorites/cubit/favorites_cubit.dart';
import 'package:movie_explorer/features/home/cubit/home_cubit.dart';

/// Registers what the app's Pages resolve from `getIt`, backed by
/// [movieRepository]. App-level widget tests then never touch assets,
/// databases, latency or the network.
///
/// Pair it with `tearDown(getIt.reset)`, so each test starts from a clean
/// container.
void registerTestDependencies({required MovieRepository movieRepository}) {
  getIt
    ..registerFactory(() => GetTrendingMoviesUseCase(movieRepository))
    ..registerFactory(() => GetMovieDetailsUseCase(movieRepository))
    ..registerFactory(() => WatchFavoriteIdsUseCase(movieRepository))
    ..registerFactory(() => WatchFavoriteMoviesUseCase(movieRepository))
    ..registerFactory(() => ToggleFavoriteUseCase(movieRepository))
    ..registerFactory(() => HomeCubit(getIt(), getIt(), getIt()))
    ..registerFactory(() => FavoritesCubit(getIt(), getIt()))
    ..registerFactoryParam<MovieDetailsCubit, int, Movie?>(
      (movieId, preview) =>
          MovieDetailsCubit(movieId, preview, getIt(), getIt(), getIt()),
    );
}
