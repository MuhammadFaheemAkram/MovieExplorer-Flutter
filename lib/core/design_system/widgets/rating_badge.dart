import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/theme/app_colors.dart';
import 'package:movie_explorer/core/design_system/theme/app_spacing.dart';

/// Compact rating pill (star + one-decimal score), drawn over posters.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});

  /// Score out of 10.
  final double rating;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final score = rating.toStringAsFixed(1);
    return Semantics(
      label: 'Rating $score out of 10',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: appColors.badgeScrim,
          shape: const StadiumBorder(),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xSmall,
            vertical: AppSpacing.xxSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 14, color: appColors.ratingStar),
              const SizedBox(width: 2),
              Text(
                score,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
