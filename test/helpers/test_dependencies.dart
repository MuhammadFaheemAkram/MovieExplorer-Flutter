import 'package:movie_explorer/di/injection.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';
import 'package:movie_explorer/domain/repository/settings_repository.dart';
import 'package:movie_explorer/domain/usecase/get_movie_details_use_case.dart';
import 'package:movie_explorer/domain/usecase/get_settings_use_case.dart';
import 'package:movie_explorer/domain/usecase/get_trending_movies_use_case.dart';
import 'package:movie_explorer/domain/usecase/search_movies_use_case.dart';
import 'package:movie_explorer/domain/usecase/toggle_favorite_use_case.dart';
import 'package:movie_explorer/domain/usecase/update_language_use_case.dart';
import 'package:movie_explorer/domain/usecase/update_theme_mode_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_favorite_ids_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_favorite_movies_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_settings_use_case.dart';
import 'package:movie_explorer/features/details/cubit/movie_details_cubit.dart';
import 'package:movie_explorer/features/favorites/cubit/favorites_cubit.dart';
import 'package:movie_explorer/features/home/cubit/home_cubit.dart';
import 'package:movie_explorer/features/search/bloc/search_bloc.dart';
import 'package:movie_explorer/features/settings/cubit/settings_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Registers everything the app resolves from `getIt`, backed by fakes. App-
/// level widget tests then never touch assets, databases, preferences,
/// latency or the network.
///
/// Search runs with no debounce, so tests only need to pump. Pair this with
/// `tearDown(getIt.reset)`, so each test starts from a clean container.
void registerTestDependencies({
  required MovieRepository movieRepository,
  required SettingsRepository settingsRepository,
}) {
  getIt
    ..registerFactory(() => GetTrendingMoviesUseCase(movieRepository))
    ..registerFactory(() => GetMovieDetailsUseCase(movieRepository))
    ..registerFactory(() => SearchMoviesUseCase(movieRepository))
    ..registerFactory(() => WatchFavoriteIdsUseCase(movieRepository))
    ..registerFactory(() => WatchFavoriteMoviesUseCase(movieRepository))
    ..registerFactory(() => ToggleFavoriteUseCase(movieRepository))
    ..registerFactory(() => GetSettingsUseCase(settingsRepository))
    ..registerFactory(() => WatchSettingsUseCase(settingsRepository))
    ..registerFactory(() => UpdateThemeModeUseCase(settingsRepository))
    ..registerFactory(() => UpdateLanguageUseCase(settingsRepository))
    ..registerFactory(() => HomeCubit(getIt(), getIt(), getIt()))
    ..registerFactory(() => FavoritesCubit(getIt(), getIt()))
    ..registerFactory(() => SearchBloc(getIt(), debounce: Duration.zero))
    ..registerFactory(() => SettingsCubit(getIt(), getIt(), getIt(), getIt()))
    ..registerFactoryParam<MovieDetailsCubit, int, Movie?>(
      (movieId, preview) =>
          MovieDetailsCubit(movieId, preview, getIt(), getIt(), getIt()),
    )
    ..registerSingleton(
      PackageInfo(
        appName: 'MovieExplorer',
        packageName: 'co.bitfuse.flutter.movie_explorer',
        version: '1.0.0',
        buildNumber: '1',
      ),
    );
}
