import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';

/// Adds a movie to favorites, or removes it if it is already there.
///
/// Callers don't update any UI themselves. The favorites streams emit the new
/// state, so every screen updates from the same source.
@injectable
class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repository);

  final MovieRepository _repository;

  Future<Result<void>> call(Movie movie) => _repository.toggleFavorite(movie);
}
