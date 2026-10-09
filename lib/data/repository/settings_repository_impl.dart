import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/storage/settings_local_data_source.dart';
import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';
import 'package:movie_explorer/domain/repository/settings_repository.dart';

/// The default [SettingsRepository].
///
/// It keeps the current [AppSettings] in memory, publishes every change to
/// its watchers immediately, and persists through [SettingsLocalDataSource].
/// Stored values are enum names, and unknown or missing values fall back to
/// the defaults.
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local) : _current = _read(_local);

  final SettingsLocalDataSource _local;
  final _changes = StreamController<AppSettings>.broadcast(sync: true);
  AppSettings _current;

  @override
  AppSettings get currentSettings => _current;

  @override
  Stream<AppSettings> watchSettings() {
    // Emit the current value on listen, then every change. Subscribing to
    // changes in the same step leaves no gap for an update to slip through.
    StreamSubscription<AppSettings>? changes;
    late final StreamController<AppSettings> controller;
    controller = StreamController<AppSettings>(
      onListen: () {
        controller.add(_current);
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () async {
        await changes?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> updateThemeMode(AppThemeMode mode) {
    _publish(_current.copyWith(themeMode: mode));
    return _local.setThemeMode(mode.name);
  }

  @override
  Future<void> updateLanguage(ContentLanguage language) {
    _publish(_current.copyWith(language: language));
    return _local.setLanguage(language.name);
  }

  /// Closes the change stream. The app never calls this, because the
  /// repository lives as long as the app; tests call it to clean up. (An
  /// injectable `@disposeMethod` can't be used here: the registration is the
  /// `SettingsRepository` interface, which has no `dispose`.)
  Future<void> dispose() => _changes.close();

  void _publish(AppSettings settings) {
    if (settings == _current) return;
    _current = settings;
    _changes.add(settings);
  }

  static AppSettings _read(SettingsLocalDataSource local) => AppSettings(
    themeMode:
        AppThemeMode.values.asNameMap()[local.themeMode] ?? AppThemeMode.system,
    language:
        ContentLanguage.values.asNameMap()[local.language] ??
        ContentLanguage.en,
  );
}
