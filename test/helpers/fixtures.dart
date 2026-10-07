import 'package:movie_explorer/core/network/dto/movie_dto.dart';
import 'package:movie_explorer/domain/model/movie.dart';

// Test data mirroring the first entries of assets/json/trending_movies.json.
//
// The domain fixtures have no poster URLs, so widget tests render the offline
// fallback deterministically instead of attempting network image loads.

const nebulasEdge = Movie(
  id: 101,
  title: "Nebula's Edge",
  overview: 'A salvage crew chasing a derelict freighter at the rim of space.',
  rating: 8.2,
  releaseYear: '2023',
  genres: ['Science Fiction', 'Adventure'],
);

const silentHarbor = Movie(
  id: 102,
  title: 'The Silent Harbor',
  overview: 'A retired lighthouse keeper takes in a stranger during a storm.',
  rating: 7.6,
  releaseYear: '2022',
  genres: ['Drama', 'Thriller'],
);

const testMovies = [nebulasEdge, silentHarbor];

const nebulasEdgeDto = MovieDto(
  id: 101,
  title: "Nebula's Edge",
  overview: 'A salvage crew chasing a derelict freighter at the rim of space.',
  voteAverage: 8.2,
  releaseDate: '2023-09-15',
  posterUrl: 'https://picsum.photos/seed/nebulas-edge/300/450',
  backdropUrl: 'https://picsum.photos/seed/nebulas-edge-bd/780/440',
  genres: ['Science Fiction', 'Adventure'],
);

const silentHarborDto = MovieDto(
  id: 102,
  title: 'The Silent Harbor',
  overview: 'A retired lighthouse keeper takes in a stranger during a storm.',
  voteAverage: 7.6,
  releaseDate: '2022-03-04',
  genres: ['Drama', 'Thriller'],
);
