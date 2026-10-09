import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/features/details/cubit/movie_details_cubit.dart';
import 'package:movie_explorer/features/details/cubit/movie_details_state.dart';

/// Renders [MovieDetailsState]: a collapsing backdrop, the poster (the `Hero`
/// target), facts, genres, the favorite toggle and the overview.
class MovieDetailsView extends StatelessWidget {
  const MovieDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
      builder: (context, state) {
        final cubit = context.read<MovieDetailsCubit>();
        return switch (state) {
          MovieDetailsLoading() => Scaffold(
            appBar: AppBar(title: const Text('Details')),
            body: const LoadingView(),
          ),
          MovieDetailsError(:final message) => Scaffold(
            appBar: AppBar(title: const Text('Details')),
            body: ErrorView(message: message, onRetry: cubit.load),
          ),
          MovieDetailsLoaded(:final movie) => _MovieDetailsContent(
            movie: movie,
            onToggleFavorite: cubit.toggleFavorite,
          ),
        };
      },
    );
  }
}

class _MovieDetailsContent extends StatelessWidget {
  const _MovieDetailsContent({
    required this.movie,
    required this.onToggleFavorite,
  });

  final Movie movie;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            // A backdrop behind the back button keeps it readable both over
            // the image and on the collapsed bar.
            leading: Padding(
              padding: const EdgeInsets.all(AppSpacing.xSmall),
              child: BackButton(
                style: IconButton.styleFrom(
                  backgroundColor: appColors.badgeScrim,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: PosterImage(
                url: movie.backdropUrl ?? movie.posterUrl,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            sliver: SliverList.list(
              children: [
                _Header(movie: movie),
                if (movie.genres.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Wrap(
                    spacing: AppSpacing.xSmall,
                    runSpacing: AppSpacing.xSmall,
                    children: [
                      for (final genre in movie.genres) GenreChip(label: genre),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.medium),
                _FavoriteToggle(
                  isFavorite: movie.isFavorite,
                  onPressed: onToggleFavorite,
                ),
                const SizedBox(height: AppSpacing.large),
                Text('Overview', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xSmall),
                Text(
                  movie.overview,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Hero(
          tag: HeroTags.poster(movie.id),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: SizedBox(
              width: 100,
              height: 150,
              child: PosterImage(url: movie.posterUrl),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xSmall),
              Row(
                children: [
                  RatingBadge(rating: movie.rating),
                  const SizedBox(width: AppSpacing.xSmall),
                  Text(
                    movie.releaseYear,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FavoriteToggle extends StatelessWidget {
  const _FavoriteToggle({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isFavorite) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: context.appColors.favorite,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.favorite),
        label: const Text('In favorites'),
      );
    }
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: const Icon(Icons.favorite_border),
      label: const Text('Add to favorites'),
    );
  }
}
