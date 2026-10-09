import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/navigation/app_shell.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/features/details/movie_details_page.dart';
import 'package:movie_explorer/features/favorites/favorites_page.dart';
import 'package:movie_explorer/features/home/home_page.dart';
import 'package:movie_explorer/features/search/search_page.dart';
import 'package:movie_explorer/features/settings/settings_page.dart';

part 'app_routes.g.dart';

// Typed routes: every destination is a class, and `go_router_builder`
// generates its path parsing, `location` getter and `go`/`push` helpers. A
// typo or a missing parameter becomes a compile error instead of a runtime
// "page not found" (the Dart equivalent of the iOS `Route` enum).

/// The bottom-navigation shell: one branch per tab.
///
/// `StatefulShellRoute` gives every tab its own Navigator (back stack) and keeps
/// inactive tabs alive in an IndexedStack. Switching tabs therefore preserves
/// both the pushed screens and the scroll position, like one NavigationStack
/// per tab on iOS.
@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [
        TypedGoRoute<HomeRoute>(
          path: '/home',
          routes: [TypedGoRoute<HomeMovieDetailsRoute>(path: 'movie/:id')],
        ),
      ],
    ),
    TypedStatefulShellBranch<SearchBranch>(
      routes: [
        TypedGoRoute<SearchRoute>(
          path: '/search',
          routes: [TypedGoRoute<SearchMovieDetailsRoute>(path: 'movie/:id')],
        ),
      ],
    ),
    TypedStatefulShellBranch<FavoritesBranch>(
      routes: [
        TypedGoRoute<FavoritesRoute>(
          path: '/favorites',
          routes: [TypedGoRoute<FavoritesMovieDetailsRoute>(path: 'movie/:id')],
        ),
      ],
    ),
    TypedStatefulShellBranch<SettingsBranch>(
      routes: [TypedGoRoute<SettingsRoute>(path: '/settings')],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return AppShell(navigationShell: navigationShell);
  }
}

// Branches: a named navigator key per tab makes each back stack addressable
// (and readable in debugging tools).

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'homeTab');
}

class SearchBranch extends StatefulShellBranchData {
  const SearchBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'searchTab');
}

class FavoritesBranch extends StatefulShellBranchData {
  const FavoritesBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'favoritesTab');
}

class SettingsBranch extends StatefulShellBranchData {
  const SettingsBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'settingsTab');
}

// Tab roots.

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

class SearchRoute extends GoRouteData with $SearchRoute {
  const SearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SearchPage();
}

class FavoritesRoute extends GoRouteData with $FavoritesRoute {
  const FavoritesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FavoritesPage();
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

// Details is a child of each list tab, so it is pushed *inside* the current tab
// (the tab bar stays visible and each tab keeps its own back stack). Each tab
// needs its own route class because each has its own path; all three build the
// same page.
//
// `$extra` carries the movie the list already has, as a *preview*. Details can
// then render at once, and the poster `Hero` has a target while the transition
// runs. Extras aren't part of the URL, so a deep link simply starts from the
// loading state.

/// `/home/movie/:id`
class HomeMovieDetailsRoute extends GoRouteData with $HomeMovieDetailsRoute {
  const HomeMovieDetailsRoute({required this.id, this.$extra});

  final int id;
  final Movie? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MovieDetailsPage(movieId: id, preview: $extra);
}

/// `/search/movie/:id`
class SearchMovieDetailsRoute extends GoRouteData
    with $SearchMovieDetailsRoute {
  const SearchMovieDetailsRoute({required this.id, this.$extra});

  final int id;
  final Movie? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MovieDetailsPage(movieId: id, preview: $extra);
}

/// `/favorites/movie/:id`
class FavoritesMovieDetailsRoute extends GoRouteData
    with $FavoritesMovieDetailsRoute {
  const FavoritesMovieDetailsRoute({required this.id, this.$extra});

  final int id;
  final Movie? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MovieDetailsPage(movieId: id, preview: $extra);
}
