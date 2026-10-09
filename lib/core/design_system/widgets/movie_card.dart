import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/theme/app_radius.dart';
import 'package:movie_explorer/core/design_system/theme/app_spacing.dart';
import 'package:movie_explorer/core/design_system/widgets/favorite_button.dart';
import 'package:movie_explorer/core/design_system/widgets/poster_image.dart';
import 'package:movie_explorer/core/design_system/widgets/rating_badge.dart';
import 'package:movie_explorer/domain/model/movie.dart';

/// Grid card: a poster with a rating badge and an optional heart, then the
/// title and release year.
///
/// Interaction is delegated through [onTap] and [onToggleFavorite], so the card
/// holds no navigation or business logic and can be reused anywhere. The poster
/// takes whatever height is left after the text, so the card never overflows
/// at large text sizes.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onToggleFavorite,
    this.heroTag,
  });

  final Movie movie;
  final VoidCallback? onTap;

  /// Shows the heart button when non-null.
  final VoidCallback? onToggleFavorite;

  /// When set, the poster becomes one end of a `Hero` animation.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onToggleFavorite = this.onToggleFavorite;
    final heroTag = this.heroTag;
    const radius = BorderRadius.all(Radius.circular(AppRadius.medium));

    Widget poster = ClipRRect(
      borderRadius: radius,
      child: PosterImage(url: movie.posterUrl),
    );
    if (heroTag != null) poster = Hero(tag: heroTag, child: poster);

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                poster,
                Positioned(
                  top: AppSpacing.xSmall,
                  left: AppSpacing.xSmall,
                  child: RatingBadge(rating: movie.rating),
                ),
                if (onToggleFavorite != null)
                  Positioned(
                    top: AppSpacing.xxSmall,
                    right: AppSpacing.xxSmall,
                    child: FavoriteButton(
                      isFavorite: movie.isFavorite,
                      onPressed: onToggleFavorite,
                      overImage: true,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            movie.title,
            style: theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            movie.releaseYear,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
