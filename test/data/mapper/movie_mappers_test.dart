import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/network/dto/movie_dto.dart';
import 'package:movie_explorer/data/mapper/movie_mappers.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('MovieDto.toDomain', () {
    test('maps every field and derives the release year', () {
      final movie = nebulasEdgeDto.toDomain();

      expect(movie.id, 101);
      expect(movie.title, "Nebula's Edge");
      expect(movie.overview, nebulasEdgeDto.overview);
      expect(movie.rating, 8.2);
      expect(movie.releaseYear, '2023');
      expect(movie.posterUrl, nebulasEdgeDto.posterUrl);
      expect(movie.backdropUrl, nebulasEdgeDto.backdropUrl);
      expect(movie.genres, ['Science Fiction', 'Adventure']);
    });

    test('never marks a network movie as a favorite', () {
      expect(nebulasEdgeDto.toDomain().isFavorite, isFalse);
    });

    test('turns blank URLs into null so the UI can show its fallback', () {
      const dto = MovieDto(
        id: 1,
        title: 'No art',
        overview: '',
        voteAverage: 5,
        releaseDate: '2021-01-01',
        posterUrl: '  ',
        backdropUrl: '',
      );

      final movie = dto.toDomain();

      expect(movie.posterUrl, isNull);
      expect(movie.backdropUrl, isNull);
    });

    test('uses an empty year when the release date is too short', () {
      const dto = MovieDto(
        id: 1,
        title: 'Undated',
        overview: '',
        voteAverage: 5,
        releaseDate: '',
      );

      expect(dto.toDomain().releaseYear, '');
    });
  });
}
