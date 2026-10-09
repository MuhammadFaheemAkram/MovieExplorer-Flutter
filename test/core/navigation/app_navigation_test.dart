import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/app/movie_explorer_app.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/di/injection.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';

import '../../helpers/fakes/fake_movie_repository.dart';
import '../../helpers/fakes/fake_settings_repository.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  late FakeMovieRepository repository;
  late FakeSettingsRepository settings;

  setUp(() {
    repository = FakeMovieRepository(movies: testMovies);
    settings = FakeSettingsRepository();
    registerTestDependencies(
      movieRepository: repository,
      settingsRepository: settings,
    );
  });

  tearDown(() async {
    await getIt.reset();
    await repository.dispose();
    await settings.dispose();
  });

  Future<void> pumpMovieExplorer(WidgetTester tester) async {
    tester.usePhoneSurface();
    await tester.pumpWidget(const MovieExplorerApp());
    await tester.pumpAndSettle();
  }

  // Scoped to the NavigationBar: "Search" is also the Search screen's title.
  Finder destination(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  Future<void> tapDestination(WidgetTester tester, String label) async {
    await tester.tap(destination(label));
    await tester.pumpAndSettle();
  }

  Future<void> openFirstMovie(WidgetTester tester) async {
    await tester.tap(find.text("Nebula's Edge"));
    await tester.pumpAndSettle();
  }

  group('App navigation', () {
    testWidgets('starts on the Home tab with four destinations', (
      tester,
    ) async {
      await pumpMovieExplorer(tester);

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.destinations, hasLength(4));
      expect(navigationBar.selectedIndex, 0);
      expect(find.widgetWithText(AppBar, 'Trending'), findsOneWidget);
    });

    testWidgets('Home shows the trending movies', (tester) async {
      await pumpMovieExplorer(tester);

      expect(find.byType(MovieCard), findsNWidgets(testMovies.length));
      expect(find.text("Nebula's Edge"), findsOneWidget);
    });

    testWidgets('each destination shows its own screen', (tester) async {
      await pumpMovieExplorer(tester);

      await tapDestination(tester, 'Search');
      expect(find.widgetWithText(AppBar, 'Search'), findsOneWidget);

      await tapDestination(tester, 'Favorites');
      expect(find.widgetWithText(AppBar, 'Favorites'), findsOneWidget);

      await tapDestination(tester, 'Settings');
      expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);

      await tapDestination(tester, 'Home');
      expect(find.widgetWithText(AppBar, 'Trending'), findsOneWidget);
    });

    testWidgets('tapping a movie pushes its details inside the tab, and the '
        'back button returns to the grid', (tester) async {
      await pumpMovieExplorer(tester);

      await openFirstMovie(tester);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text(nebulasEdge.overview), findsOneWidget);
      // The shell's tab bar stays visible above pushed screens.
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Trending'), findsOneWidget);
    });

    testWidgets('a details screen pushed in Home survives a tab switch', (
      tester,
    ) async {
      await pumpMovieExplorer(tester);
      await openFirstMovie(tester);

      await tapDestination(tester, 'Search');
      // Home's stack is kept alive offstage, so it isn't visible here...
      expect(find.text('Overview'), findsNothing);

      await tapDestination(tester, 'Home');
      // ...and it is still on top of the stack when we come back.
      expect(find.text('Overview'), findsOneWidget);
    });

    testWidgets('re-tapping the active tab pops it back to its root', (
      tester,
    ) async {
      await pumpMovieExplorer(tester);
      await openFirstMovie(tester);

      await tapDestination(tester, 'Home');

      expect(find.text('Overview'), findsNothing);
      expect(find.widgetWithText(AppBar, 'Trending'), findsOneWidget);
    });
  });

  group('Favorites across tabs (single source of truth)', () {
    testWidgets('a movie favorited on Home appears in Favorites, and removing '
        'it there clears the heart on Home', (tester) async {
      await pumpMovieExplorer(tester);

      await tester.tap(find.byTooltip('Add to favorites').first);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remove from favorites'), findsOneWidget);

      await tapDestination(tester, 'Favorites');
      expect(find.byType(MovieRow), findsOneWidget);
      expect(find.text("Nebula's Edge"), findsOneWidget);

      await tester.tap(find.byTooltip('Remove from favorites'));
      await tester.pumpAndSettle();
      expect(find.text('No favorites yet'), findsOneWidget);

      await tapDestination(tester, 'Home');
      expect(find.byTooltip('Remove from favorites'), findsNothing);
      expect(find.byTooltip('Add to favorites'), findsNWidgets(2));
    });

    testWidgets('the Details heart and the Home heart stay in sync', (
      tester,
    ) async {
      await pumpMovieExplorer(tester);
      await openFirstMovie(tester);

      await tester.tap(find.text('Add to favorites'));
      await tester.pumpAndSettle();
      expect(find.text('In favorites'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    });
  });

  group('Search tab', () {
    testWidgets('typing finds movies, and a result opens its details inside '
        'the Search tab', (tester) async {
      await pumpMovieExplorer(tester);
      await tapDestination(tester, 'Search');

      await tester.enterText(find.byType(TextField), 'harbor');
      await tester.pumpAndSettle();
      expect(find.byType(MovieRow), findsOneWidget);

      await tester.tap(find.text('The Silent Harbor'));
      await tester.pumpAndSettle();
      expect(find.text('Overview'), findsOneWidget);
      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, 1);
    });
  });

  group('Settings (app-scoped)', () {
    testWidgets('choosing Dark restyles the whole app', (tester) async {
      await pumpMovieExplorer(tester);
      await tapDestination(tester, 'Settings');

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(settings.currentSettings.themeMode, AppThemeMode.dark);
    });

    testWidgets('a saved appearance applies from the first frame', (
      tester,
    ) async {
      await settings.updateThemeMode(AppThemeMode.light);

      await pumpMovieExplorer(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);
    });

    testWidgets('the content language reaches the Home badge', (tester) async {
      await pumpMovieExplorer(tester);
      expect(find.text('EN'), findsOneWidget);

      await settings.updateLanguage(ContentLanguage.es);
      await tester.pumpAndSettle();

      expect(find.text('ES'), findsOneWidget);
    });
  });
}
