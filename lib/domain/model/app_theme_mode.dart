/// The user's appearance choice.
///
/// It is a domain enum, deliberately Flutter-free; `app/` maps it to Flutter's
/// `ThemeMode`. `system` follows the device setting.
enum AppThemeMode {
  system('System'),
  light('Light'),
  dark('Dark');

  const AppThemeMode(this.displayName);

  final String displayName;
}
