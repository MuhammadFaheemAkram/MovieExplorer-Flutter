import 'package:injectable/injectable.dart';
import 'package:movie_explorer/core/common/result.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/domain/repository/movie_repository.dart';

/// Loads one movie's details by id.
@injectable
class GetMovieDetailsUseCase {
  const GetMovieDetailsUseCase(this._repository);

  final MovieRepository _repository;

  Future<Result<Movie>> call(int id) => _repository.getMovieDetails(id);
}
