import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/features/favorites/cubit/favorites_cubit.dart';
import 'package:movie_explorer/features/favorites/cubit/favorites_state.dart';

/// Renders [FavoritesState]: an offline list where each row can be removed by
/// swiping or by tapping its heart.
class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key, required this.onMovieTap});

  final ValueChanged<Movie> onMovieTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) => switch (state) {
          FavoritesLoading() => const LoadingView(),
          FavoritesEmpty() => const EmptyStateView(
            icon: Icons.favorite_border,
            title: 'No favorites yet',
            message:
                'Movies you favorite appear here and stay available offline.',
          ),
          FavoritesLoaded(:final movies) => ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) => _FavoriteTile(
              movie: movies[index],
              onTap: onMovieTap,
              onRemove: context.read<FavoritesCubit>().remove,
            ),
          ),
        },
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.movie,
    required this.onTap,
    required this.onRemove,
  });

  final Movie movie;
  final ValueChanged<Movie> onTap;
  final ValueChanged<Movie> onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(movie.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(movie),
      background: ColoredBox(
        color: colors.errorContainer,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.large),
            child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
          ),
        ),
      ),
      child: MovieRow(
        movie: movie,
        heroTag: HeroTags.poster(movie.id),
        onTap: () => onTap(movie),
        trailing: FavoriteButton(
          isFavorite: true,
          onPressed: () => onRemove(movie),
        ),
      ),
    );
  }
}
