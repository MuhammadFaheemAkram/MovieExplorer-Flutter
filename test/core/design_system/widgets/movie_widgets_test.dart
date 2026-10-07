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

  group('MovieCard', () {
    testWidgets('shows title, year and rating, and reports taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpThemed(
        SizedBox(
          width: 180,
          height: 330,
          child: MovieCard(movie: nebulasEdge, onTap: () => taps++),
        ),
      );

      expect(find.text("Nebula's Edge"), findsOneWidget);
      expect(find.text('2023'), findsOneWidget);
      expect(find.text('8.2'), findsOneWidget);

      await tester.tap(find.byType(MovieCard));
      expect(taps, 1);
    });

    testWidgets('does not overflow at a large text scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: SizedBox(
                width: 180,
                height: 330,
                child: MovieCard(movie: nebulasEdge, onTap: () {}),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
