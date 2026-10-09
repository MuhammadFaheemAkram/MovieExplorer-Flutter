import 'package:injectable/injectable.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/repository/settings_repository.dart';

/// Persists the appearance choice; watchers see it immediately.
@injectable
class UpdateThemeModeUseCase {
  const UpdateThemeModeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(AppThemeMode mode) => _repository.updateThemeMode(mode);
}
