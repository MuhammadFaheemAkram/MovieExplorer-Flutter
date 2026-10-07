import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/app/movie_explorer_app.dart';

void main() {
  Future<void> pumpMovieExplorer(WidgetTester tester) async {
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

  Future<void> openSampleDetails(WidgetTester tester) async {
    await tester.tap(find.text('Open sample details'));
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

    testWidgets('details are pushed inside the tab and the back button '
        'returns to the tab root', (tester) async {
      await pumpMovieExplorer(tester);

      await openSampleDetails(tester);
      expect(find.text('Movie #101'), findsOneWidget);
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
      await openSampleDetails(tester);

      await tapDestination(tester, 'Search');
      // Home's stack is kept alive offstage, so it isn't visible here...
      expect(find.text('Movie #101'), findsNothing);

      await tapDestination(tester, 'Home');
      // ...and it is still on top of the stack when we come back.
      expect(find.text('Movie #101'), findsOneWidget);
    });

    testWidgets('re-tapping the active tab pops it back to its root', (
      tester,
    ) async {
      await pumpMovieExplorer(tester);
      await openSampleDetails(tester);

      await tapDestination(tester, 'Home');

      expect(find.text('Movie #101'), findsNothing);
      expect(find.widgetWithText(AppBar, 'Trending'), findsOneWidget);
    });
  });
}
