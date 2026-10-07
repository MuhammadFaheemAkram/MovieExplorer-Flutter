import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/common/app_exception.dart';
import 'package:movie_explorer/core/network/asset_json_loader.dart';
import 'package:movie_explorer/core/network/fake_movie_api_service.dart';

/// Serves in-memory strings as assets, to feed the service broken catalogs.
class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<ByteData> load(String key) async {
    final value = _assets[key];
    if (value == null) throw StateError('No test asset for $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

void main() {
  // Lets `rootBundle` read the app's real bundled assets inside tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  FakeMovieApiService serviceWith({
    AssetBundle? bundle,
    bool simulateErrors = false,
  }) {
    return FakeMovieApiService(
      AssetJsonLoader(bundle ?? rootBundle),
      simulateErrors: simulateErrors,
      latencyFactor: 0,
    );
  }

  FakeMovieApiService serviceWithCatalog(String catalogJson) => serviceWith(
    bundle: _StringAssetBundle({FakeMovieApiService.catalogPath: catalogJson}),
  );

  group('FakeMovieApiService with the bundled catalog', () {
    late FakeMovieApiService service;

    setUp(() => service = serviceWith());

    test('fetchTrendingMovies decodes all 12 movies in order', () async {
      final movies = await service.fetchTrendingMovies();

      expect(movies, hasLength(12));
      expect(movies.first.id, 101);
      expect(movies.first.title, "Nebula's Edge");
    });

    test('searchMovies matches titles case-insensitively', () async {
      final movies = await service.searchMovies('NEBULA');

      expect(movies.map((movie) => movie.id), [101]);
    });

    test('searchMovies matches genres too', () async {
      final movies = await service.searchMovies('horror');

      expect(movies.map((movie) => movie.title), ['Whispers in the Fog']);
    });

    test('searchMovies ignores overviews', () async {
      // "cartographer" appears in Crimson Vale's overview but only in one title.
      final movies = await service.searchMovies('cartographer');

      expect(movies.map((movie) => movie.id), [107]);
    });

    test('searchMovies returns nothing for a blank query', () async {
      expect(await service.searchMovies('   '), isEmpty);
    });

    test('fetchMovieDetails finds a movie by id', () async {
      final movie = await service.fetchMovieDetails(105);

      expect(movie.title, 'Iron Meridian');
    });

    test('fetchMovieDetails throws NotFoundException for an unknown id', () {
      expect(service.fetchMovieDetails(999), throwsA(isA<NotFoundException>()));
    });
  });

  group('FakeMovieApiService failures', () {
    test(
      'every endpoint throws NetworkException when errors are simulated',
      () {
        final service = serviceWith(simulateErrors: true);

        expect(service.fetchTrendingMovies(), throwsA(isA<NetworkException>()));
        expect(service.searchMovies('edge'), throwsA(isA<NetworkException>()));
        expect(
          service.fetchMovieDetails(101),
          throwsA(isA<NetworkException>()),
        );
      },
    );

    test('malformed JSON becomes a DataFormatException', () {
      expect(
        serviceWithCatalog('{ not json').fetchTrendingMovies(),
        throwsA(isA<DataFormatException>()),
      );
    });

    test('a JSON object instead of an array becomes a DataFormatException', () {
      expect(
        serviceWithCatalog('{"id": 1}').fetchTrendingMovies(),
        throwsA(isA<DataFormatException>()),
      );
    });

    test('a mistyped field becomes a DataFormatException', () {
      const catalog =
          '[{"id": "101", "title": "X", "overview": "", '
          '"vote_average": 1, "release_date": "2020"}]';

      expect(
        serviceWithCatalog(catalog).fetchTrendingMovies(),
        throwsA(isA<DataFormatException>()),
      );
    });
  });
}
