import 'package:injectable/injectable.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';

/// Streams the ids of all favorited movies. Every heart in the app follows it.
@injectable
class WatchFavoriteIdsUseCase {
  const WatchFavoriteIdsUseCase(this._repository);

  final MovieRepository _repository;

  Stream<Set<int>> call() => _repository.watchFavoriteIds();
}
