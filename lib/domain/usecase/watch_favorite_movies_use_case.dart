import 'package:injectable/injectable.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';

/// Streams the favorited movies, newest first. It emits again on every change.
@injectable
class WatchFavoriteMoviesUseCase {
  const WatchFavoriteMoviesUseCase(this._repository);

  final MovieRepository _repository;

  Stream<List<Movie>> call() => _repository.watchFavoriteMovies();
}
