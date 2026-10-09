import 'package:async/async.dart' show StreamQueue;
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/storage/settings_local_data_source.dart';
import 'package:movie_explorer/data/repository/settings_repository_impl.dart';
import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../helpers/stream_helpers.dart';

void main() {
  setUp(() {
    // An in-memory platform store: real SharedPreferencesWithCache code paths,
    // with no device storage.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<SettingsLocalDataSource> createDataSource() async =>
      SettingsLocalDataSource(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: SettingsLocalDataSource.allowList,
          ),
        ),
      );

  Future<SettingsRepositoryImpl> createRepository() async {
    final repository = SettingsRepositoryImpl(await createDataSource());
    addTearDown(repository.dispose);
    return repository;
  }

  test('defaults to System appearance and English', () async {
    final repository = await createRepository();

    expect(repository.currentSettings, const AppSettings());
  });

  test('emits the current settings, then every change', () async {
    final repository = await createRepository();
    final settings = StreamQueue(repository.watchSettings());
    addTearDown(settings.cancel);

    expect(await nextEvent(settings), const AppSettings());

    await repository.updateThemeMode(AppThemeMode.dark);
    expect(
      await nextEvent(settings),
      const AppSettings(themeMode: AppThemeMode.dark),
    );

    await repository.updateLanguage(ContentLanguage.ur);
    expect(
      await nextEvent(settings),
      const AppSettings(
        themeMode: AppThemeMode.dark,
        language: ContentLanguage.ur,
      ),
    );
  });

  test('a new instance reads the persisted values', () async {
    final first = await createRepository();
    await first.updateThemeMode(AppThemeMode.light);
    await first.updateLanguage(ContentLanguage.de);

    final second = await createRepository();

    expect(
      second.currentSettings,
      const AppSettings(
        themeMode: AppThemeMode.light,
        language: ContentLanguage.de,
      ),
    );
  });

  test('falls back to the defaults for unknown stored values', () async {
    final dataSource = await createDataSource();
    await dataSource.setThemeMode('purple');
    await dataSource.setLanguage('xx');

    final repository = await createRepository();

    expect(repository.currentSettings, const AppSettings());
  });
}
