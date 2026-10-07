import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';

/// Loads the trending movies.
///
/// Use cases are deliberately thin. Each one names a single operation, so a
/// Cubit depends only on what it actually does rather than on the whole
/// repository.
@injectable
class GetTrendingMoviesUseCase {
  const GetTrendingMoviesUseCase(this._repository);

  final MovieRepository _repository;

  Future<Result<List<Movie>>> call() => _repository.getTrendingMovies();
}
