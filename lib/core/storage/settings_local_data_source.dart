import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the raw preference values. The keys live here and nowhere
/// else.
///
/// It is backed by `SharedPreferencesWithCache`. That is created once before
/// `runApp` (see `AppModule`), so reads are synchronous afterwards and writes
/// update the cache immediately and the disk asynchronously.
@lazySingleton
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._preferences);

  static const themeModeKey = 'settings.themeMode';
  static const languageKey = 'settings.language';

  /// The only keys the cache loads and allows writing.
  static const allowList = {themeModeKey, languageKey};

  final SharedPreferencesWithCache _preferences;

  String? get themeMode => _preferences.getString(themeModeKey);

  String? get language => _preferences.getString(languageKey);

  Future<void> setThemeMode(String value) =>
      _preferences.setString(themeModeKey, value);

  Future<void> setLanguage(String value) =>
      _preferences.setString(languageKey, value);
}
