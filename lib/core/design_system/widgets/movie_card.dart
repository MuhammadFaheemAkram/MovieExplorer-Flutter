import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/theme/app_radius.dart';
import 'package:movie_explorer/core/design_system/theme/app_spacing.dart';
import 'package:movie_explorer/core/design_system/widgets/poster_image.dart';
import 'package:movie_explorer/core/design_system/widgets/rating_badge.dart';
import 'package:movie_explorer/domain/model/movie.dart';

/// Grid card: a poster with a rating badge, then the title and release year.
///
/// Interaction is delegated through [onTap], so the card holds no navigation
/// or business logic and can be reused anywhere. The poster takes whatever
/// height is left after the text, so the card never overflows at large text
/// sizes.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, this.onTap});

  final Movie movie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const radius = BorderRadius.all(Radius.circular(AppRadius.medium));
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
                ClipRRect(
                  borderRadius: radius,
                  child: PosterImage(url: movie.posterUrl),
                ),
                Positioned(
                  top: AppSpacing.xSmall,
                  left: AppSpacing.xSmall,
                  child: RatingBadge(rating: movie.rating),
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
