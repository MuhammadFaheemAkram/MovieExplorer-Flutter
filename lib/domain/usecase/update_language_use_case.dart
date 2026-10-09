import 'package:injectable/injectable.dart';
import 'package:movie_explorer/domain/model/content_language.dart';
import 'package:movie_explorer/domain/repository/settings_repository.dart';

/// Persists the content-language choice; watchers see it immediately.
@injectable
class UpdateLanguageUseCase {
  const UpdateLanguageUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(ContentLanguage language) =>
      _repository.updateLanguage(language);
}
