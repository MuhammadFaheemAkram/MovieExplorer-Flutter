import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';

/// Maps the Flutter-free domain choice to Flutter's [ThemeMode]. Because this
/// mapping lives in the app layer, the domain never imports Flutter.
extension AppThemeModeX on AppThemeMode {
  ThemeMode toThemeMode() => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
