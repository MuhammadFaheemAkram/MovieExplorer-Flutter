import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/database/app_database.dart';
import 'package:movie_explorer/core/database/daos/favorites_dao.dart';
import 'package:movie_explorer/core/storage/settings_local_data_source.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers objects that can't carry injectable annotations themselves:
/// Flutter, drift and third-party types (the equivalent of a Hilt `@Module`).
@module
abstract class AppModule {
  /// The real asset bundle. Tests build their own `AssetJsonLoader` with a
  /// fake bundle instead.
  @lazySingleton
  AssetBundle get assetBundle => rootBundle;

  /// One database for the whole app. Opening several connections to the same
  /// SQLite file would break drift's change notifications.
  @lazySingleton
  AppDatabase get appDatabase => AppDatabase();

  @lazySingleton
  FavoritesDao favoritesDao(AppDatabase database) => database.favoritesDao;

  /// `@preResolve` awaits this before `runApp`, so preferences can be read
  /// synchronously from the first frame.
  @preResolve
  @lazySingleton
  Future<SharedPreferencesWithCache> get preferences =>
      SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: SettingsLocalDataSource.allowList,
        ),
      );

  /// App name, version and build number for the About section.
  @preResolve
  @lazySingleton
  Future<PackageInfo> get packageInfo => PackageInfo.fromPlatform();
}
