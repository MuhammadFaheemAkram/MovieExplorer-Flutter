import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  group('RatingBadge', () {
    testWidgets('shows the score with one decimal', (tester) async {
      await tester.pumpThemed(const RatingBadge(rating: 7));

      expect(find.text('7.0'), findsOneWidget);
    });

    testWidgets('announces the rating to screen readers', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpThemed(const RatingBadge(rating: 8.2));

      expect(find.bySemanticsLabel('Rating 8.2 out of 10'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('PosterImage', () {
    testWidgets('shows the film fallback when there is no URL', (tester) async {
      await tester.pumpThemed(
        const SizedBox(width: 100, height: 150, child: PosterImage(url: null)),
      );

      expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
    });
  });

  group('FavoriteButton', () {
    testWidgets('describes the action it will perform', (tester) async {
      await tester.pumpThemed(
        FavoriteButton(isFavorite: false, onPressed: () {}),
      );
      expect(find.byTooltip('Add to favorites'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.pumpThemed(
        FavoriteButton(isFavorite: true, onPressed: () {}),
      );
      expect(find.byTooltip('Remove from favorites'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('reports taps', (tester) async {
      var taps = 0;
      await tester.pumpThemed(
        FavoriteButton(isFavorite: false, onPressed: () => taps++),
      );

      await tester.tap(find.byType(FavoriteButton));

      expect(taps, 1);
    });
  });

  group('MovieCard', () {
    Widget card({VoidCallback? onTap, VoidCallback? onToggleFavorite}) =>
        SizedBox(
          width: 180,
          height: 330,
          child: MovieCard(
            movie: nebulasEdge,
            onTap: onTap,
            onToggleFavorite: onToggleFavorite,
          ),
        );

    testWidgets('shows title, year and rating, and reports taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpThemed(card(onTap: () => taps++));

      expect(find.text("Nebula's Edge"), findsOneWidget);
      expect(find.text('2023'), findsOneWidget);
      expect(find.text('8.2'), findsOneWidget);

      await tester.tap(find.text("Nebula's Edge"));
      expect(taps, 1);
    });

    testWidgets('shows the heart only when it can be toggled', (tester) async {
      await tester.pumpThemed(card());
      expect(find.byType(FavoriteButton), findsNothing);

      var toggles = 0;
      await tester.pumpThemed(card(onToggleFavorite: () => toggles++));
      await tester.tap(find.byType(FavoriteButton));
      expect(toggles, 1);
    });

    testWidgets('does not overflow at a large text scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: card(onTap: () {}, onToggleFavorite: () {}),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('MovieRow', () {
    testWidgets('shows title, year, rating and the trailing widget', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpThemed(
        MovieRow(
          movie: silentHarbor,
          onTap: () => taps++,
          trailing: const Icon(Icons.chevron_right),
        ),
      );

      expect(find.text('The Silent Harbor'), findsOneWidget);
      expect(find.text('2022'), findsOneWidget);
      expect(find.text('7.6'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.text('The Silent Harbor'));
      expect(taps, 1);
    });
  });

  group('GenreChip', () {
    testWidgets('shows its label', (tester) async {
      await tester.pumpThemed(const GenreChip(label: 'Drama'));

      expect(find.widgetWithText(Chip, 'Drama'), findsOneWidget);
    });
  });
}
