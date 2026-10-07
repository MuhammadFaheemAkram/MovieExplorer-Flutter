import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';

/// Searches movies by title or genre.
@injectable
class SearchMoviesUseCase {
  const SearchMoviesUseCase(this._repository);

  final MovieRepository _repository;

  /// A blank query has no results by definition, so it never reaches the
  /// repository.
  Future<Result<List<Movie>>> call(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const Ok(<Movie>[]);
    return _repository.searchMovies(trimmed);
  }
}
