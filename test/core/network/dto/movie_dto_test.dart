import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:movie_explorer/core/network/dto/movie_dto.dart';

void main() {
  group('MovieDto.fromJson', () {
    test('reads the snake_case keys of the API payload', () {
      final dto = MovieDto.fromJson({
        'id': 105,
        'title': 'Iron Meridian',
        'overview': 'An engineer races a shrinking clock.',
        'poster_url': 'https://example.com/poster.jpg',
        'backdrop_url': 'https://example.com/backdrop.jpg',
        'vote_average': 8.5,
        'release_date': '2023-05-19',
        'genres': ['Action', 'Science Fiction'],
      });

      expect(dto.id, 105);
      expect(dto.title, 'Iron Meridian');
      expect(dto.posterUrl, 'https://example.com/poster.jpg');
      expect(dto.backdropUrl, 'https://example.com/backdrop.jpg');
      expect(dto.voteAverage, 8.5);
      expect(dto.releaseDate, '2023-05-19');
      expect(dto.genres, ['Action', 'Science Fiction']);
    });

    test('treats optional fields as absent and accepts integer ratings', () {
      final dto = MovieDto.fromJson({
        'id': 1,
        'title': 'Minimal',
        'overview': '',
        'vote_average': 8,
        'release_date': '2020-01-01',
      });

      expect(dto.posterUrl, isNull);
      expect(dto.backdropUrl, isNull);
      expect(dto.genres, isEmpty);
      expect(dto.voteAverage, 8.0);
    });

    test('reports a mistyped field as a CheckedFromJsonException', () {
      expect(
        () => MovieDto.fromJson({
          'id': 1,
          'title': 42,
          'overview': '',
          'vote_average': 8,
          'release_date': '2020-01-01',
        }),
        throwsA(
          isA<CheckedFromJsonException>().having((e) => e.key, 'key', 'title'),
        ),
      );
    });
  });
}
