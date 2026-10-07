import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie.freezed.dart';

/// A movie as the app understands it, independent of any JSON or database
/// shape. Features and Cubits depend only on this type.
///
/// `freezed` generates value equality, `copyWith` and `toString`, and makes
/// [genres] unmodifiable, so a `Movie` can never change after it is created.
@freezed
abstract class Movie with _$Movie {
  const factory Movie({
    required int id,
    required String title,
    required String overview,
    required double rating,

    /// The first four characters of the release date, e.g. `2023`.
    required String releaseYear,
    String? posterUrl,
    String? backdropUrl,
    @Default(<String>[]) List<String> genres,

    /// Never set by the network. Screens overlay it from the favorites store,
    /// the single source of truth for what is favorited (Phase 3).
    @Default(false) bool isFavorite,
  }) = _Movie;
}
