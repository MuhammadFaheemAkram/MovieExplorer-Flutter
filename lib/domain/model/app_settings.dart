import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';

part 'app_settings.freezed.dart';

/// All persisted preferences as one immutable value. It is observed as a
/// stream, so a change reaches every screen (and the app's theme) at once.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    @Default(ContentLanguage.en) ContentLanguage language,
  }) = _AppSettings;
}
