import 'package:async/async.dart' show StreamQueue;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/core/database/app_database.dart';
import 'package:movie_explorer/core/database/daos/favorites_dao.dart';
import 'package:movie_explorer/data/mapper/favorite_movie_mappers.dart';
import 'package:movie_explorer/domain/model/movie.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/stream_helpers.dart';

void main() {
  late AppDatabase database;
  late FavoritesDao dao;

  setUp(() {
    // A fresh in-memory SQLite database per test: no disk, no shared state.
    database = AppDatabase(NativeDatabase.memory());
    dao = database.favoritesDao;
  });

  tearDown(() => database.close());

  FavoriteMoviesCompanion row(Movie movie, DateTime addedAt) =>
      movie.toFavoriteCompanion(addedAt: addedAt);

  final noon = DateTime.utc(2026, 10, 9, 12);

  group('FavoritesDao', () {
    test('toggle inserts a favorite, then removes it', () async {
      expect(await dao.toggle(row(nebulasEdge, noon)), isTrue);
      expect(await dao.findById(101), isNotNull);

      expect(await dao.toggle(row(nebulasEdge, noon)), isFalse);
      expect(await dao.findById(101), isNull);
    });

    test('watchAll lists favorites newest first', () async {
      await dao.toggle(row(nebulasEdge, noon));
      await dao.toggle(row(silentHarbor, noon.add(const Duration(days: 1))));

      final rows = await dao.watchAll().first;

      expect(rows.map((favorite) => favorite.id), [102, 101]);
    });

    test('keeps newest-first order within the same second', () async {
      // With drift's default (whole Unix seconds) these two would tie. The
      // ISO-8601 text option in build.yaml keeps sub-second precision.
      await dao.toggle(
        row(silentHarbor, noon.add(const Duration(milliseconds: 5))),
      );
      await dao.toggle(row(nebulasEdge, noon));

      final rows = await dao.watchAll().first;

      expect(rows.map((favorite) => favorite.id), [102, 101]);
    });

    test('watchAll emits the current snapshot, then every change', () async {
      final ids = StreamQueue(
        dao.watchAll().map((rows) => [for (final row in rows) row.id]),
      );
      addTearDown(ids.cancel);

      // Wait for the initial query before writing (conventions §11.3).
      expect(await nextEvent(ids), isEmpty);
      await dao.toggle(row(nebulasEdge, noon));
      expect(await nextEvent(ids), [101]);
      await dao.toggle(row(nebulasEdge, noon));
      expect(await nextEvent(ids), isEmpty);
    });

    test('watchIds emits the set of favorite ids', () async {
      final ids = StreamQueue(dao.watchIds());
      addTearDown(ids.cancel);

      expect(await nextEvent(ids), isEmpty);
      await dao.toggle(row(silentHarbor, noon));
      expect(await nextEvent(ids), {102});
    });

    test('genres and missing URLs survive the round trip', () async {
      final movie = nebulasEdge.copyWith(
        genres: ['Science Fiction', 'Drama & "Mystery", too'],
      );

      await dao.toggle(row(movie, noon));
      final stored = await dao.findById(101);

      expect(stored!.genres, ['Science Fiction', 'Drama & "Mystery", too']);
      expect(stored.posterUrl, isNull);
      expect(stored.addedAt, noon);
    });
  });
}
