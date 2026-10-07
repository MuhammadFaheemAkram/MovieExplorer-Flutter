import 'package:injectable/injectable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:movie_explorer/core/common/app_config.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/network/asset_json_loader.dart';
import 'package:movie_explorer/core/network/dto/movie_dto.dart';
import 'package:movie_explorer/core/network/movie_api_service.dart';

/// A [MovieApiService] backed by bundled JSON instead of a server.
///
/// It behaves like a real client (simulated latency, optional failures, DTO
/// decoding), so everything above it (repository, Cubits, UI) runs exactly as
/// it would against a live backend. All three "endpoints" read the same
/// catalog file. A real backend would serve them separately, but callers
/// can't tell the difference.
@LazySingleton(as: MovieApiService)
class FakeMovieApiService implements MovieApiService {
  FakeMovieApiService(
    this._loader, {
    @ignoreParam this.simulateErrors = AppConfig.simulateNetworkErrors,
    @ignoreParam this.latencyFactor = 1.0,
  });

  static const catalogPath = 'assets/json/trending_movies.json';

  final AssetJsonLoader _loader;

  /// When true, every call fails with a [NetworkException].
  final bool simulateErrors;

  /// Scales the simulated latency; tests pass `0` for instant replies.
  final double latencyFactor;

  @override
  Future<List<MovieDto>> fetchTrendingMovies() async {
    await _simulateNetwork(const Duration(milliseconds: 800));
    return _catalog();
  }

  @override
  Future<List<MovieDto>> searchMovies(String query) async {
    await _simulateNetwork(const Duration(milliseconds: 400));
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    final catalog = await _catalog();
    return [
      for (final movie in catalog)
        if (movie.title.toLowerCase().contains(needle) ||
            movie.genres.any((genre) => genre.toLowerCase().contains(needle)))
          movie,
    ];
  }

  @override
  Future<MovieDto> fetchMovieDetails(int id) async {
    await _simulateNetwork(const Duration(milliseconds: 500));
    final catalog = await _catalog();
    return catalog.firstWhere(
      (movie) => movie.id == id,
      orElse: () => throw const NotFoundException(),
    );
  }

  Future<void> _simulateNetwork(Duration latency) async {
    await Future<void>.delayed(latency * latencyFactor);
    if (simulateErrors) throw const NetworkException();
  }

  Future<List<MovieDto>> _catalog() async {
    try {
      final objects = await _loader.loadObjectList(catalogPath);
      return objects.map(MovieDto.fromJson).toList();
    } on FormatException {
      throw const DataFormatException();
    } on CheckedFromJsonException {
      throw const DataFormatException();
    }
  }
}
