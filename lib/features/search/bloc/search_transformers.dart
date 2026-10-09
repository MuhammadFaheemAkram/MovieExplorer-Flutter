import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer/features/search/bloc/search_event.dart';
import 'package:stream_transform/stream_transform.dart';

/// Debounce + restartable, the reason Search is a Bloc rather than a Cubit.
///
/// - **Blank queries pass straight through.** Clearing the field goes idle at
///   once, and `switchMap` drops any search still waiting out its delay.
/// - **Other queries are debounced.** Each keystroke replaces the pending
///   delayed event (`switchMap` to a delayed value *is* a debounce), so only
///   the last query typed within [duration] runs.
/// - **Restartable.** If a newer query arrives while a search is in flight, the
///   older handler is cancelled and its late result is never emitted.
EventTransformer<SearchQueryChanged> debounceRestartable(Duration duration) {
  return (events, mapper) => restartable<SearchQueryChanged>()(
    events.switchMap(
      (event) => event.query.trim().isEmpty
          ? Stream.value(event)
          : Stream.fromFuture(
              Future<SearchQueryChanged>.delayed(duration, () => event),
            ),
    ),
    mapper,
  );
}
