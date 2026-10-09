import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';

void main() {
  group('AppTheme', () {
    test('builds Material 3 light and dark themes', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();

      expect(light.useMaterial3, isTrue);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
    });

    test('registers the matching AppColors extension for each brightness', () {
      expect(AppTheme.light().extension<AppColors>(), same(AppColors.light));
      expect(AppTheme.dark().extension<AppColors>(), same(AppColors.dark));
    });
  });

  group('AppColors', () {
    test('lerp interpolates every token', () {
      final mid = AppColors.light.lerp(AppColors.dark, 0.5);

      expect(
        mid.favorite,
        Color.lerp(AppColors.light.favorite, AppColors.dark.favorite, 0.5),
      );
      expect(
        mid.onFavorite,
        Color.lerp(AppColors.light.onFavorite, AppColors.dark.onFavorite, 0.5),
      );
      expect(
        mid.ratingStar,
        Color.lerp(AppColors.light.ratingStar, AppColors.dark.ratingStar, 0.5),
      );
      expect(
        mid.badgeScrim,
        Color.lerp(AppColors.light.badgeScrim, AppColors.dark.badgeScrim, 0.5),
      );
    });

    test('lerp towards a missing extension keeps the current colors', () {
      expect(AppColors.light.lerp(null, 0.5), same(AppColors.light));
    });

    test('copyWith replaces only the given tokens', () {
      const purple = Color(0xFF7B1FA2);
      final copy = AppColors.light.copyWith(favorite: purple);

      expect(copy.favorite, purple);
      expect(copy.onFavorite, AppColors.light.onFavorite);
      expect(copy.ratingStar, AppColors.light.ratingStar);
      expect(copy.badgeScrim, AppColors.light.badgeScrim);
    });

    test('"In favorites" text meets WCAG AA contrast in both themes', () {
      // Regression: white on the dark theme's lighter red was only ~2.8:1.
      double contrast(Color a, Color b) {
        final (hi, lo) = (a.computeLuminance(), b.computeLuminance());
        return hi > lo ? (hi + 0.05) / (lo + 0.05) : (lo + 0.05) / (hi + 0.05);
      }

      for (final colors in [AppColors.light, AppColors.dark]) {
        expect(
          contrast(colors.onFavorite, colors.favorite),
          greaterThanOrEqualTo(4.5),
        );
      }
    });
  });
}
