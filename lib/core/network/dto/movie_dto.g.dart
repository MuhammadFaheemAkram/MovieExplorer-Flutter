// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieDto _$MovieDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MovieDto',
  json,
  ($checkedConvert) {
    final val = MovieDto(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      title: $checkedConvert('title', (v) => v as String),
      overview: $checkedConvert('overview', (v) => v as String),
      voteAverage: $checkedConvert(
        'vote_average',
        (v) => (v as num).toDouble(),
      ),
      releaseDate: $checkedConvert('release_date', (v) => v as String),
      posterUrl: $checkedConvert('poster_url', (v) => v as String?),
      backdropUrl: $checkedConvert('backdrop_url', (v) => v as String?),
      genres: $checkedConvert(
        'genres',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'voteAverage': 'vote_average',
    'releaseDate': 'release_date',
    'posterUrl': 'poster_url',
    'backdropUrl': 'backdrop_url',
  },
);
