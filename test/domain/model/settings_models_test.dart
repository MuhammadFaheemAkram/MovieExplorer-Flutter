import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/app/theme_mode_mapper.dart';
import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';

void main() {
  test('settings default to the system appearance and English', () {
    const settings = AppSettings();

    expect(settings.themeMode, AppThemeMode.system);
    expect(settings.language, ContentLanguage.en);
  });

  test('every appearance maps to the matching Flutter ThemeMode', () {
    expect(AppThemeMode.system.toThemeMode(), ThemeMode.system);
    expect(AppThemeMode.light.toThemeMode(), ThemeMode.light);
    expect(AppThemeMode.dark.toThemeMode(), ThemeMode.dark);
  });

  test('languages show their native name and a short code', () {
    expect(ContentLanguage.ar.displayName, 'العربية');
    expect(ContentLanguage.ur.code, 'UR');
    expect(ContentLanguage.values, hasLength(5));
  });
}
