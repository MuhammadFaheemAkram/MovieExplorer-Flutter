import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/theme/app_radius.dart';
import 'package:movie_explorer/core/design_system/theme/app_spacing.dart';
import 'package:movie_explorer/core/design_system/widgets/poster_image.dart';
import 'package:movie_explorer/core/design_system/widgets/rating_badge.dart';
import 'package:movie_explorer/domain/model/movie.dart';

/// List row: a poster thumbnail, title and year, and the rating, plus an
/// optional [trailing] widget (e.g. a heart). Used by Favorites and Search.
class MovieRow extends StatelessWidget {
  const MovieRow({
    super.key,
    required this.movie,
    this.onTap,
    this.trailing,
    this.heroTag,
  });

  final Movie movie;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// When set, the thumbnail becomes one end of a `Hero` animation.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroTag = this.heroTag;
    final trailing = this.trailing;
    Widget thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: SizedBox(
        width: 46,
        height: 69,
        child: PosterImage(url: movie.posterUrl),
      ),
    );
    if (heroTag != null) thumbnail = Hero(tag: heroTag, child: thumbnail);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.xSmall,
        ),
        child: Row(
          children: [
            thumbnail,
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxSmall),
                  Text(
                    movie.releaseYear,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            RatingBadge(rating: movie.rating),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.xxSmall),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}
