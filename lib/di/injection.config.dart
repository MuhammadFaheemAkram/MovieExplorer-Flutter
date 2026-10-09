// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flutter/services.dart' as _i281;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:movie_explorer/core/database/app_database.dart' as _i717;
import 'package:movie_explorer/core/database/daos/favorites_dao.dart' as _i188;
import 'package:movie_explorer/core/network/asset_json_loader.dart' as _i375;
import 'package:movie_explorer/core/network/fake_movie_api_service.dart'
    as _i321;
import 'package:movie_explorer/core/network/movie_api_service.dart' as _i639;
import 'package:movie_explorer/core/storage/settings_local_data_source.dart'
    as _i1063;
import 'package:movie_explorer/data/repository/movie_repository_impl.dart'
    as _i920;
import 'package:movie_explorer/data/repository/settings_repository_impl.dart'
    as _i636;
import 'package:movie_explorer/di/app_module.dart' as _i645;
import 'package:movie_explorer/domain/model/movie.dart' as _i1056;
import 'package:movie_explorer/domain/repository/movie_repository.dart'
    as _i1028;
import 'package:movie_explorer/domain/repository/settings_repository.dart'
    as _i61;
import 'package:movie_explorer/domain/usecase/get_movie_details_use_case.dart'
    as _i285;
import 'package:movie_explorer/domain/usecase/get_settings_use_case.dart'
    as _i722;
import 'package:movie_explorer/domain/usecase/get_trending_movies_use_case.dart'
    as _i938;
import 'package:movie_explorer/domain/usecase/search_movies_use_case.dart'
    as _i177;
import 'package:movie_explorer/domain/usecase/toggle_favorite_use_case.dart'
    as _i209;
import 'package:movie_explorer/domain/usecase/update_language_use_case.dart'
    as _i1051;
import 'package:movie_explorer/domain/usecase/update_theme_mode_use_case.dart'
    as _i674;
import 'package:movie_explorer/domain/usecase/watch_favorite_ids_use_case.dart'
    as _i48;
import 'package:movie_explorer/domain/usecase/watch_favorite_movies_use_case.dart'
    as _i90;
import 'package:movie_explorer/domain/usecase/watch_settings_use_case.dart'
    as _i289;
import 'package:movie_explorer/features/details/cubit/movie_details_cubit.dart'
    as _i23;
import 'package:movie_explorer/features/favorites/cubit/favorites_cubit.dart'
    as _i0;
import 'package:movie_explorer/features/home/cubit/home_cubit.dart' as _i135;
import 'package:movie_explorer/features/search/bloc/search_bloc.dart' as _i539;
import 'package:movie_explorer/features/settings/cubit/settings_cubit.dart'
    as _i771;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i281.AssetBundle>(() => appModule.assetBundle);
    gh.lazySingleton<_i717.AppDatabase>(() => appModule.appDatabase);
    await gh.lazySingletonAsync<_i460.SharedPreferencesWithCache>(
      () => appModule.preferences,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i655.PackageInfo>(
      () => appModule.packageInfo,
      preResolve: true,
    );
    gh.lazySingleton<_i1063.SettingsLocalDataSource>(
      () => _i1063.SettingsLocalDataSource(
        gh<_i460.SharedPreferencesWithCache>(),
      ),
    );
    gh.lazySingleton<_i375.AssetJsonLoader>(
      () => _i375.AssetJsonLoader(gh<_i281.AssetBundle>()),
    );
    gh.lazySingleton<_i188.FavoritesDao>(
      () => appModule.favoritesDao(gh<_i717.AppDatabase>()),
    );
    gh.lazySingleton<_i61.SettingsRepository>(
      () => _i636.SettingsRepositoryImpl(gh<_i1063.SettingsLocalDataSource>()),
    );
    gh.lazySingleton<_i639.MovieApiService>(
      () => _i321.FakeMovieApiService(gh<_i375.AssetJsonLoader>()),
    );
    gh.lazySingleton<_i1028.MovieRepository>(
      () => _i920.MovieRepositoryImpl(
        gh<_i639.MovieApiService>(),
        gh<_i188.FavoritesDao>(),
      ),
    );
    gh.factory<_i285.GetMovieDetailsUseCase>(
      () => _i285.GetMovieDetailsUseCase(gh<_i1028.MovieRepository>()),
    );
    gh.factory<_i938.GetTrendingMoviesUseCase>(
      () => _i938.GetTrendingMoviesUseCase(gh<_i1028.MovieRepository>()),
    );
    gh.factory<_i177.SearchMoviesUseCase>(
      () => _i177.SearchMoviesUseCase(gh<_i1028.MovieRepository>()),
    );
    gh.factory<_i209.ToggleFavoriteUseCase>(
      () => _i209.ToggleFavoriteUseCase(gh<_i1028.MovieRepository>()),
    );
    gh.factory<_i48.WatchFavoriteIdsUseCase>(
      () => _i48.WatchFavoriteIdsUseCase(gh<_i1028.MovieRepository>()),
    );
    gh.factory<_i90.WatchFavoriteMoviesUseCase>(
      () => _i90.WatchFavoriteMoviesUseCase(gh<_i1028.MovieRepository>()),
    );
    gh.factory<_i722.GetSettingsUseCase>(
      () => _i722.GetSettingsUseCase(gh<_i61.SettingsRepository>()),
    );
    gh.factory<_i1051.UpdateLanguageUseCase>(
      () => _i1051.UpdateLanguageUseCase(gh<_i61.SettingsRepository>()),
    );
    gh.factory<_i674.UpdateThemeModeUseCase>(
      () => _i674.UpdateThemeModeUseCase(gh<_i61.SettingsRepository>()),
    );
    gh.factory<_i289.WatchSettingsUseCase>(
      () => _i289.WatchSettingsUseCase(gh<_i61.SettingsRepository>()),
    );
    gh.factoryParam<_i23.MovieDetailsCubit, int, _i1056.Movie?>(
      (movieId, preview) => _i23.MovieDetailsCubit(
        movieId,
        preview,
        gh<_i285.GetMovieDetailsUseCase>(),
        gh<_i48.WatchFavoriteIdsUseCase>(),
        gh<_i209.ToggleFavoriteUseCase>(),
      ),
    );
    gh.factory<_i771.SettingsCubit>(
      () => _i771.SettingsCubit(
        gh<_i722.GetSettingsUseCase>(),
        gh<_i289.WatchSettingsUseCase>(),
        gh<_i674.UpdateThemeModeUseCase>(),
        gh<_i1051.UpdateLanguageUseCase>(),
      ),
    );
    gh.factory<_i135.HomeCubit>(
      () => _i135.HomeCubit(
        gh<_i938.GetTrendingMoviesUseCase>(),
        gh<_i48.WatchFavoriteIdsUseCase>(),
        gh<_i209.ToggleFavoriteUseCase>(),
      ),
    );
    gh.factory<_i539.SearchBloc>(
      () => _i539.SearchBloc(gh<_i177.SearchMoviesUseCase>()),
    );
    gh.factory<_i0.FavoritesCubit>(
      () => _i0.FavoritesCubit(
        gh<_i90.WatchFavoriteMoviesUseCase>(),
        gh<_i209.ToggleFavoriteUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i645.AppModule {}
