import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/features/home/cubit/home_cubit.dart';
import 'package:movie_explorer/features/home/cubit/home_state.dart';
import 'package:movie_explorer/features/home/widgets/movie_grid.dart';

/// Renders [HomeState] and forwards user intents to [HomeCubit].
///
/// It holds no business logic and doesn't know about routes (the Page passes
/// [onMovieTap]), so widget tests can drive it with a mocked Cubit.
class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.onMovieTap});

  final ValueChanged<Movie> onMovieTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending')),
      body: BlocConsumer<HomeCubit, HomeState>(
        // One-time effect: report a failed refresh once, without replacing the
        // movies already on screen.
        listenWhen: (previous, current) =>
            _refreshError(current) != null &&
            _refreshError(current) != _refreshError(previous),
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(_refreshError(state)!)));
        },
        builder: (context, state) {
          final cubit = context.read<HomeCubit>();
          return switch (state) {
            HomeLoading() => const LoadingView(
              message: 'Loading trending movies…',
            ),
            HomeEmpty() => EmptyStateView(
              icon: Icons.local_movies_outlined,
              title: 'No movies',
              message: 'There are no trending movies right now.',
              action: FilledButton.tonal(
                onPressed: cubit.load,
                child: const Text('Refresh'),
              ),
            ),
            HomeError(:final message) => ErrorView(
              message: message,
              onRetry: cubit.load,
            ),
            HomeLoaded(:final movies) => RefreshIndicator(
              onRefresh: cubit.refresh,
              child: MovieGrid(
                movies: movies,
                onMovieTap: onMovieTap,
                onToggleFavorite: cubit.toggleFavorite,
              ),
            ),
          };
        },
      ),
    );
  }

  static String? _refreshError(HomeState state) =>
      state is HomeLoaded ? state.refreshErrorMessage : null;
}
