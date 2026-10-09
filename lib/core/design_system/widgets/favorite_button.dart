import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/theme/app_colors.dart';

/// Heart toggle used on cards and rows.
///
/// It is purely presentational: it shows [isFavorite] and reports taps. The
/// favorite state itself lives in the store. The tooltip doubles as the
/// screen-reader label.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.overImage = false,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  /// Draws a translucent backdrop so the icon stays visible on posters.
  final bool overImage;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return IconButton(
      onPressed: onPressed,
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      color: isFavorite
          ? appColors.favorite
          : overImage
          ? Colors.white
          : Theme.of(context).colorScheme.onSurfaceVariant,
      style: overImage
          ? IconButton.styleFrom(backgroundColor: appColors.badgeScrim)
          : null,
    );
  }
}
