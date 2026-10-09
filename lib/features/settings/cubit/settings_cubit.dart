import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';
import 'package:movie_explorer/domain/usecase/get_settings_use_case.dart';
import 'package:movie_explorer/domain/usecase/update_language_use_case.dart';
import 'package:movie_explorer/domain/usecase/update_theme_mode_use_case.dart';
import 'package:movie_explorer/domain/usecase/watch_settings_use_case.dart';

/// App-scoped settings: one instance, provided *above* `MaterialApp.router`.
///
/// - The app root reads `themeMode` from it.
/// - The Settings screen reads and changes the settings through it.
/// - Home shows the language badge from it.
///
/// It is a Cubit, not a Bloc. It is app-wide, but its intents are two plain
/// setters, with no event semantics (debouncing, cancellation) that would
/// justify events. Its first state comes synchronously from the repository,
/// so the saved theme applies from the very first frame.
@injectable
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(
    GetSettingsUseCase getSettings,
    WatchSettingsUseCase watchSettings,
    this._updateThemeMode,
    this._updateLanguage,
  ) : super(getSettings()) {
    _subscription = watchSettings().listen((settings) {
      if (settings != state) emit(settings);
    });
  }

  final UpdateThemeModeUseCase _updateThemeMode;
  final UpdateLanguageUseCase _updateLanguage;
  late final StreamSubscription<AppSettings> _subscription;

  /// The store publishes the change and this Cubit re-emits it, so there is
  /// exactly one path for new settings to reach the UI.
  Future<void> selectThemeMode(AppThemeMode mode) => _updateThemeMode(mode);

  Future<void> selectLanguage(ContentLanguage language) =>
      _updateLanguage(language);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
