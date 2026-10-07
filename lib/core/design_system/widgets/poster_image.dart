import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/theme/app_icon_size.dart';

/// A network poster with a consistent placeholder and failure state.
///
/// Posters are the only content that isn't bundled with the app. Offline they
/// fall back to a film icon and everything else keeps working. Fills whatever
/// box the parent gives it and crops to fit.
class PosterImage extends StatelessWidget {
  const PosterImage({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) return const _PosterFallback();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, _) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      errorWidget: (_, _, _) => const _PosterFallback(),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: AppIconSize.medium,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
