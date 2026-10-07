import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a themed [MaterialApp] and [Scaffold], which is
  /// enough context for any single design-system widget or screen view.
  Future<void> pumpThemed(Widget widget, {ThemeData? theme}) {
    return pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light(),
        home: Scaffold(body: widget),
      ),
    );
  }
}
