import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/theme/app_colors.dart';
import 'package:movie_explorer/core/design_system/theme/app_radius.dart';

/// Builds the app's Material 3 light and dark themes from one seed color.
///
/// Screens style themselves through `Theme.of(context)`, never with hard-coded
/// colors, so a re-brand is a one-line change here. The seed is the iOS
/// edition's brand color, so all three editions share an identity.
abstract final class AppTheme {
  static const Color seedColor = Color(0xFF4D5CE6);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      // `fidelity` keeps the primary color close to the brand seed; the
      // default variant (`tonalSpot`) would noticeably mute it.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );

    return ThemeData(
      colorScheme: colorScheme,
      extensions: [
        if (brightness == Brightness.light) AppColors.light else AppColors.dark,
      ],
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
