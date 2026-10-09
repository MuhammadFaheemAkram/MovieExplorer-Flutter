import 'dart:async';

import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';
import 'package:movie_explorer/domain/repository/settings_repository.dart';

/// In-memory [SettingsRepository]. Like the real one, `watchSettings` emits
/// the current value on listen and every change after it.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this._current = const AppSettings()]);

  AppSettings _current;
  final _changes = StreamController<AppSettings>.broadcast(sync: true);

  @override
  AppSettings get currentSettings => _current;

  @override
  Stream<AppSettings> watchSettings() {
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
  Future<void> updateThemeMode(AppThemeMode mode) async =>
      _publish(_current.copyWith(themeMode: mode));

  @override
  Future<void> updateLanguage(ContentLanguage language) async =>
      _publish(_current.copyWith(language: language));

  Future<void> dispose() => _changes.close();

  void _publish(AppSettings settings) {
    _current = settings;
    _changes.add(settings);
  }
}
