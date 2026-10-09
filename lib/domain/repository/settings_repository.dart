import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';

/// Contract for the user's preferences.
///
/// It hides the storage (shared_preferences), so widgets never read
/// preferences directly and tests can swap in a fake.
abstract interface class SettingsRepository {
  /// The current settings, available synchronously. The app reads them before
  /// its first frame, so a saved dark theme never flashes light.
  AppSettings get currentSettings;

  /// Emits the current settings immediately, then again after every change.
  Stream<AppSettings> watchSettings();

  Future<void> updateThemeMode(AppThemeMode mode);

  Future<void> updateLanguage(ContentLanguage language);
}
