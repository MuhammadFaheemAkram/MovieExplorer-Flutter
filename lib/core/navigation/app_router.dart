import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/core/navigation/app_routes.dart';

/// Creates the app's [GoRouter].
///
/// This is a factory rather than a global: the app widget owns one router for
/// its whole lifetime, and every widget test starts from a fresh one with no
/// navigation state left over from a previous test.
GoRouter createAppRouter({String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation ?? const HomeRoute().location,
    routes: $appRoutes,
    // `/` (e.g. an app link without a path) has no screen of its own, so it
    // lands on the Home tab.
    redirect: (context, state) =>
        state.uri.path == '/' ? const HomeRoute().location : null,
    errorBuilder: (context, state) =>
        _NotFoundPage(location: state.uri.toString()),
  );
}

/// Shown when a location matches no route, e.g. a mistyped deep link.
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: EmptyStateView(
        icon: Icons.explore_off_outlined,
        title: 'Page not found',
        message: 'Nothing lives at "$location".',
        action: FilledButton.tonal(
          onPressed: () => const HomeRoute().go(context),
          child: const Text('Go to Home'),
        ),
      ),
    );
  }
}
