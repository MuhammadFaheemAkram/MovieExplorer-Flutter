import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('LoadingView', () {
    testWidgets('shows a spinner and its message', (tester) async {
      await tester.pumpThemed(
        const LoadingView(message: 'Loading trending movies…'),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading trending movies…'), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgets('shows the message without a retry button by default', (
      tester,
    ) async {
      await tester.pumpThemed(const ErrorView(message: 'Network down.'));

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Network down.'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('calls onRetry when "Try again" is tapped', (tester) async {
      var retries = 0;
      await tester.pumpThemed(
        ErrorView(message: 'Network down.', onRetry: () => retries++),
      );

      await tester.tap(find.text('Try again'));

      expect(retries, 1);
    });
  });

  group('EmptyStateView', () {
    testWidgets('renders its icon, title, message and action', (tester) async {
      var taps = 0;
      await tester.pumpThemed(
        EmptyStateView(
          icon: Icons.favorite_border,
          title: 'No favorites yet',
          message: 'Movies you favorite appear here.',
          action: TextButton(
            onPressed: () => taps++,
            child: const Text('Browse movies'),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('No favorites yet'), findsOneWidget);
      expect(find.text('Movies you favorite appear here.'), findsOneWidget);
      await tester.tap(find.text('Browse movies'));
      expect(taps, 1);
    });

    testWidgets('omits the message and action when not provided', (
      tester,
    ) async {
      await tester.pumpThemed(
        const EmptyStateView(icon: Icons.search, title: 'Search movies'),
      );

      expect(find.text('Search movies'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });
  });
}
