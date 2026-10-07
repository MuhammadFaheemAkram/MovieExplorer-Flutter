// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$appShellRoute];

RouteBase get $appShellRoute => StatefulShellRouteData.$route(
  factory: $AppShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      navigatorKey: HomeBranch.$navigatorKey,
      routes: [
        GoRouteData.$route(
          path: '/home',
          hasOverriddenOnExit: false,
          factory: $HomeRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'movie/:id',
              hasOverriddenOnExit: false,
              factory: $HomeMovieDetailsRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: SearchBranch.$navigatorKey,
      routes: [
        GoRouteData.$route(
          path: '/search',
          hasOverriddenOnExit: false,
          factory: $SearchRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'movie/:id',
              hasOverriddenOnExit: false,
              factory: $SearchMovieDetailsRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: FavoritesBranch.$navigatorKey,
      routes: [
        GoRouteData.$route(
          path: '/favorites',
          hasOverriddenOnExit: false,
          factory: $FavoritesRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'movie/:id',
              hasOverriddenOnExit: false,
              factory: $FavoritesMovieDetailsRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: SettingsBranch.$navigatorKey,
      routes: [
        GoRouteData.$route(
          path: '/settings',
          hasOverriddenOnExit: false,
          factory: $SettingsRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $AppShellRouteExtension on AppShellRoute {
  static AppShellRoute _fromState(GoRouterState state) => const AppShellRoute();
}

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $HomeMovieDetailsRoute on GoRouteData {
  static HomeMovieDetailsRoute _fromState(GoRouterState state) =>
      HomeMovieDetailsRoute(id: int.parse(state.pathParameters['id']!));

  HomeMovieDetailsRoute get _self => this as HomeMovieDetailsRoute;

  @override
  String get location => GoRouteData.$location(
    '/home/movie/${Uri.encodeComponent(_self.id.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SearchRoute on GoRouteData {
  static SearchRoute _fromState(GoRouterState state) => const SearchRoute();

  @override
  String get location => GoRouteData.$location('/search');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SearchMovieDetailsRoute on GoRouteData {
  static SearchMovieDetailsRoute _fromState(GoRouterState state) =>
      SearchMovieDetailsRoute(id: int.parse(state.pathParameters['id']!));

  SearchMovieDetailsRoute get _self => this as SearchMovieDetailsRoute;

  @override
  String get location => GoRouteData.$location(
    '/search/movie/${Uri.encodeComponent(_self.id.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FavoritesRoute on GoRouteData {
  static FavoritesRoute _fromState(GoRouterState state) =>
      const FavoritesRoute();

  @override
  String get location => GoRouteData.$location('/favorites');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FavoritesMovieDetailsRoute on GoRouteData {
  static FavoritesMovieDetailsRoute _fromState(GoRouterState state) =>
      FavoritesMovieDetailsRoute(id: int.parse(state.pathParameters['id']!));

  FavoritesMovieDetailsRoute get _self => this as FavoritesMovieDetailsRoute;

  @override
  String get location => GoRouteData.$location(
    '/favorites/movie/${Uri.encodeComponent(_self.id.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
