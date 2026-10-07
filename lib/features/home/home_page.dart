import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/core/navigation/app_routes.dart';

/// Home tab. Phase 1 placeholder; Phase 2 replaces it with the trending grid.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending')),
      body: EmptyStateView(
        icon: Icons.local_movies_outlined,
        title: 'Trending movies',
        message:
            'Coming in Phase 2: a grid of trending movies from the fake API.',
        // Temporary: shows that Details is pushed inside this tab.
        action: FilledButton.tonal(
          onPressed: () =>
              const HomeMovieDetailsRoute(id: 101).push<void>(context),
          child: const Text('Open sample details'),
        ),
      ),
    );
  }
}
