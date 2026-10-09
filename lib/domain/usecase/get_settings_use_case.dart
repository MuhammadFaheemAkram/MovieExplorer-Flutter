import 'package:injectable/injectable.dart';
import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/repository/settings_repository.dart';

/// The settings right now (synchronous). Used as the Settings Cubit's initial
/// state, so the first frame already has the right theme.
@injectable
class GetSettingsUseCase {
  const GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  AppSettings call() => _repository.currentSettings;
}
