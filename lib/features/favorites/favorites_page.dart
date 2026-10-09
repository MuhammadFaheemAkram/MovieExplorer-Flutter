import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/navigation/app_routes.dart';
import 'package:movie_explorer/di/injection.dart';
import 'package:movie_explorer/features/favorites/cubit/favorites_cubit.dart';
import 'package:movie_explorer/features/favorites/favorites_view.dart';

/// Favorites tab entry point. It creates this screen's [FavoritesCubit] and
/// wires navigation; the [FavoritesView] does the rendering.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FavoritesCubit>(),
      child: FavoritesView(
        onMovieTap: (movie) => FavoritesMovieDetailsRoute(
          id: movie.id,
          $extra: movie,
        ).push<void>(context),
      ),
    );
  }
}
