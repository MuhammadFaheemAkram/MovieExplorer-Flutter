import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/core/navigation/app_routes.dart';

/// Search tab. Phase 1 placeholder; Phase 4 adds the debounced search.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: EmptyStateView(
        icon: Icons.search,
        title: 'Search movies',
        message: 'Coming in Phase 4: debounced search by title or genre.',
        // Temporary: shows that Details is pushed inside this tab.
        action: FilledButton.tonal(
          onPressed: () =>
              const SearchMovieDetailsRoute(id: 105).push<void>(context),
          child: const Text('Open sample details'),
        ),
      ),
    );
  }
}
