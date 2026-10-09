import 'package:injectable/injectable.dart';
import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/repository/settings_repository.dart';

/// Streams the settings: the current value first, then every change.
@injectable
class WatchSettingsUseCase {
  const WatchSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Stream<AppSettings> call() => _repository.watchSettings();
}
