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
import 'package:movie_explorer/core/network/asset_json_loader.dart' as _i375;
import 'package:movie_explorer/core/network/fake_movie_api_service.dart'
    as _i321;
import 'package:movie_explorer/core/network/movie_api_service.dart' as _i639;
import 'package:movie_explorer/data/repository/movie_repository_impl.dart'
    as _i920;
import 'package:movie_explorer/di/app_module.dart' as _i645;
import 'package:movie_explorer/domain/repository/movie_repository.dart'
    as _i1028;
import 'package:movie_explorer/domain/usecase/get_movie_details_use_case.dart'
    as _i285;
import 'package:movie_explorer/domain/usecase/get_trending_movies_use_case.dart'
    as _i938;
import 'package:movie_explorer/domain/usecase/search_movies_use_case.dart'
    as _i177;
import 'package:movie_explorer/features/home/cubit/home_cubit.dart' as _i135;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i281.AssetBundle>(() => appModule.assetBundle);
    gh.lazySingleton<_i375.AssetJsonLoader>(
      () => _i375.AssetJsonLoader(gh<_i281.AssetBundle>()),
    );
    gh.lazySingleton<_i639.MovieApiService>(
      () => _i321.FakeMovieApiService(gh<_i375.AssetJsonLoader>()),
    );
    gh.lazySingleton<_i1028.MovieRepository>(
      () => _i920.MovieRepositoryImpl(gh<_i639.MovieApiService>()),
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
    gh.factory<_i135.HomeCubit>(
      () => _i135.HomeCubit(gh<_i938.GetTrendingMoviesUseCase>()),
    );
    return this;
  }
}

class _$AppModule extends _i645.AppModule {}
