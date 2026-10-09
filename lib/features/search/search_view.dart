import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/features/search/bloc/search_bloc.dart';
import 'package:movie_explorer/features/search/bloc/search_event.dart';
import 'package:movie_explorer/features/search/bloc/search_state.dart';

/// Search field plus results. Every keystroke becomes a [SearchQueryChanged]
/// event; debouncing and cancellation live in the Bloc, not here.
///
/// It is a `StatefulWidget` only to own the text controller, which is
/// ephemeral UI state, not app state.
class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.onMovieTap});

  final ValueChanged<Movie> onMovieTap;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    setState(() {}); // Shows or hides the clear button.
    context.read<SearchBloc>().add(SearchQueryChanged(query));
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.xSmall,
              AppSpacing.medium,
              AppSpacing.small,
            ),
            child: SearchBar(
              controller: _controller,
              hintText: 'Title or genre',
              leading: const Icon(Icons.search),
              trailing: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    onPressed: _clear,
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close),
                  ),
              ],
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) => switch (state) {
                SearchIdle() => const EmptyStateView(
                  icon: Icons.search,
                  title: 'Search movies',
                  message: 'Find a movie by its title or genre.',
                ),
                SearchLoading() => const LoadingView(message: 'Searching…'),
                SearchNoResults(:final query) => EmptyStateView(
                  icon: Icons.search_off,
                  title: 'No results',
                  message: 'No movies match “$query”.',
                ),
                SearchError(:final message) => ErrorView(
                  message: message,
                  onRetry: () =>
                      context.read<SearchBloc>().add(const SearchRetried()),
                ),
                SearchResults(:final movies) => ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return MovieRow(
                      movie: movie,
                      heroTag: HeroTags.poster(movie.id),
                      onTap: () => widget.onMovieTap(movie),
                    );
                  },
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
