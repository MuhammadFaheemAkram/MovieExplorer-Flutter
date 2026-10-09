import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';
import 'package:movie_explorer/domain/usecase/get_settings_use_case.dart';
import 'package:movie_explorer/domain/usecase/update_language_use_case.dart';
import 'package:movie_explorer/domain/usecase/update_theme_mode_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_settings_use_case.dart';
import 'package:movie_explorer/features/settings/cubit/settings_cubit.dart';

import '../../../helpers/fakes/fake_settings_repository.dart';

void main() {
  late FakeSettingsRepository repository;

  setUp(() => repository = FakeSettingsRepository());
  tearDown(() => repository.dispose());

  SettingsCubit buildCubit() => SettingsCubit(
    GetSettingsUseCase(repository),
    WatchSettingsUseCase(repository),
    UpdateThemeModeUseCase(repository),
    UpdateLanguageUseCase(repository),
  );

  test('starts with the stored settings, so the first frame is right', () {
    repository = FakeSettingsRepository(
      const AppSettings(themeMode: AppThemeMode.dark),
    );
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.themeMode, AppThemeMode.dark);
  });

  blocTest<SettingsCubit, AppSettings>(
    'does not re-emit the initial settings from the stream',
    build: buildCubit,
    expect: () => <AppSettings>[],
  );

  blocTest<SettingsCubit, AppSettings>(
    'selectThemeMode persists and emits the new appearance',
    build: buildCubit,
    act: (cubit) => cubit.selectThemeMode(AppThemeMode.dark),
    expect: () => [const AppSettings(themeMode: AppThemeMode.dark)],
    verify: (_) =>
        expect(repository.currentSettings.themeMode, AppThemeMode.dark),
  );

  blocTest<SettingsCubit, AppSettings>(
    'selectLanguage persists and emits the new language',
    build: buildCubit,
    act: (cubit) => cubit.selectLanguage(ContentLanguage.ar),
    expect: () => [const AppSettings(language: ContentLanguage.ar)],
  );

  blocTest<SettingsCubit, AppSettings>(
    'follows changes made through the repository elsewhere',
    build: buildCubit,
    act: (_) => repository.updateLanguage(ContentLanguage.es),
    expect: () => [const AppSettings(language: ContentLanguage.es)],
  );
}
