import 'package:json_annotation/json_annotation.dart';

part 'movie_dto.g.dart';

/// A movie exactly as the (fake) API sends it.
///
/// Kept separate from the domain `Movie`, so JSON key names and wire types
/// never leak past the data layer: a backend change touches only this class
/// and its mapper.
///
/// - `fieldRename: snake` maps `posterUrl` ↔ `poster_url`, `voteAverage` ↔
///   `vote_average` and so on, with no per-field annotations.
/// - `checked: true` turns a missing or mistyped field into a
///   `CheckedFromJsonException` that names the bad key, instead of a bare
///   `TypeError`.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  checked: true,
  createToJson: false,
)
class MovieDto {
  const MovieDto({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    this.posterUrl,
    this.backdropUrl,
    this.genres = const [],
  });

  factory MovieDto.fromJson(Map<String, dynamic> json) =>
      _$MovieDtoFromJson(json);

  final int id;
  final String title;
  final String overview;
  final double voteAverage;

  /// ISO date, e.g. `2023-09-15`.
  final String releaseDate;
  final String? posterUrl;
  final String? backdropUrl;
  final List<String> genres;
}
