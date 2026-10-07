import 'package:movie_explorer/core/network/dto/movie_dto.dart';
import 'package:movie_explorer/domain/model/movie.dart';

// Mappers live in the data layer, so the DTO and the domain model never know
// about each other: either side can change without touching the other.

extension MovieDtoMapper on MovieDto {
  /// The result always has `isFavorite == false`. Favorite state belongs to the
  /// local store, never to a network response.
  Movie toDomain() => Movie(
    id: id,
    title: title,
    overview: overview,
    rating: voteAverage,
    releaseYear: releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '',
    posterUrl: _nonBlank(posterUrl),
    backdropUrl: _nonBlank(backdropUrl),
    genres: genres,
  );
}

/// Treats empty URL strings like missing ones, so the UI's fallback image
/// handles both.
String? _nonBlank(String? value) =>
    value == null || value.trim().isEmpty ? null : value;
