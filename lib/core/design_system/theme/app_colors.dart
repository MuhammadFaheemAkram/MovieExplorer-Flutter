import 'package:material_ui/material_ui.dart';

/// App-specific semantic colors that Material's [ColorScheme] has no slot for.
///
/// A [ThemeExtension] travels inside [ThemeData], so the light and dark
/// variants switch automatically (and animate via [lerp]) when the theme
/// changes. Widgets ask for an *intent* (`favorite`, `ratingStar`) instead of
/// hard-coding raw colors.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.favorite,
    required this.ratingStar,
    required this.badgeScrim,
  });

  /// Filled hearts and the "In favorites" button.
  final Color favorite;

  /// The star inside rating badges.
  final Color ratingStar;

  /// Translucent backdrop behind badges drawn on top of posters.
  final Color badgeScrim;

  static const light = AppColors(
    favorite: Color(0xFFD32F2F),
    ratingStar: Color(0xFFFFB300),
    badgeScrim: Color(0x99000000),
  );

  static const dark = AppColors(
    favorite: Color(0xFFFF6B6B),
    ratingStar: Color(0xFFFFCA28),
    badgeScrim: Color(0xB3000000),
  );

  @override
  AppColors copyWith({Color? favorite, Color? ratingStar, Color? badgeScrim}) {
    return AppColors(
      favorite: favorite ?? this.favorite,
      ratingStar: ratingStar ?? this.ratingStar,
      badgeScrim: badgeScrim ?? this.badgeScrim,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      favorite: Color.lerp(favorite, other.favorite, t)!,
      ratingStar: Color.lerp(ratingStar, other.ratingStar, t)!,
      badgeScrim: Color.lerp(badgeScrim, other.badgeScrim, t)!,
    );
  }
}

/// Shorthand for `Theme.of(context).extension<AppColors>()!`.
extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
