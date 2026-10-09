import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';
import 'package:movie_explorer/features/settings/cubit/settings_cubit.dart';
import 'package:movie_explorer/features/settings/settings_view.dart';

import '../../helpers/pump_app.dart';

class MockSettingsCubit extends MockCubit<AppSettings>
    implements SettingsCubit {}

void main() {
  late MockSettingsCubit cubit;

  setUpAll(() {
    registerFallbackValue(AppThemeMode.system);
    registerFallbackValue(ContentLanguage.en);
  });

  setUp(() {
    cubit = MockSettingsCubit();
    when(() => cubit.state).thenReturn(const AppSettings());
    when(() => cubit.selectThemeMode(any())).thenAnswer((_) async {});
    when(() => cubit.selectLanguage(any())).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester) async {
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<SettingsCubit>.value(
          value: cubit,
          child: const SettingsView(appVersion: '1.2.3 (45)'),
        ),
      ),
    );
  }

  testWidgets('shows the current appearance and language', (tester) async {
    when(() => cubit.state).thenReturn(
      const AppSettings(
        themeMode: AppThemeMode.dark,
        language: ContentLanguage.de,
      ),
    );

    await pumpView(tester);

    final segments = tester.widget<SegmentedButton<AppThemeMode>>(
      find.byType(SegmentedButton<AppThemeMode>),
    );
    expect(segments.selected, {AppThemeMode.dark});
    expect(
      find.widgetWithText(DropdownMenu<ContentLanguage>, 'Deutsch'),
      findsOneWidget,
    );
  });

  testWidgets('choosing an appearance updates the setting', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text('Dark'));

    verify(() => cubit.selectThemeMode(AppThemeMode.dark)).called(1);
  });

  testWidgets('choosing a language updates the setting', (tester) async {
    await pumpView(tester);

    await tester.tap(find.byType(DropdownMenu<ContentLanguage>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اردو').last);
    await tester.pumpAndSettle();

    verify(() => cubit.selectLanguage(ContentLanguage.ur)).called(1);
  });

  testWidgets('About shows the version and opens the licenses', (tester) async {
    await pumpView(tester);

    expect(find.text('Version 1.2.3 (45)'), findsOneWidget);
    expect(find.widgetWithText(AboutListTile, 'Licenses'), findsOneWidget);
  });
}
