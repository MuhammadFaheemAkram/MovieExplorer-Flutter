/// What can happen on the Search screen. Search is event-driven (a Bloc), so
/// every input is an explicit, testable event.
sealed class SearchEvent {
  const SearchEvent();
}

/// The text in the search field changed.
final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;
}

/// "Try again" after a failed search: re-runs the last query.
final class SearchRetried extends SearchEvent {
  const SearchRetried();
}
