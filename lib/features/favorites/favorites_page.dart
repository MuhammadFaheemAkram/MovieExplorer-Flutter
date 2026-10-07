import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/core/navigation/app_routes.dart';

/// Favorites tab. Phase 1 placeholder; Phase 3 adds the offline drift list.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: EmptyStateView(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        message: 'Coming in Phase 3: offline favorites stored with drift.',
        // Temporary: shows that Details is pushed inside this tab.
        action: FilledButton.tonal(
          onPressed: () =>
              const FavoritesMovieDetailsRoute(id: 107).push<void>(context),
          child: const Text('Open sample details'),
        ),
      ),
    );
  }
}
