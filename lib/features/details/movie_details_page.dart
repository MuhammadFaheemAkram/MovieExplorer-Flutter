import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';

/// Movie details, pushed inside whichever tab opened it.
///
/// It receives only the movie id from its typed route and will load the rest
/// itself (Phase 3). Passing ids rather than whole objects keeps routes
/// deep-linkable and the data fresh.
class MovieDetailsPage extends StatelessWidget {
  const MovieDetailsPage({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: EmptyStateView(
        icon: Icons.movie_filter_outlined,
        title: 'Movie #$movieId',
        message: 'Coming in Phase 3: backdrop, genres, overview and favorites.',
      ),
    );
  }
}
