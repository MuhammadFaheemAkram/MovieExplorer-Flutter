import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/navigation/app_routes.dart';
import 'package:movie_explorer/di/injection.dart';
import 'package:movie_explorer/features/search/bloc/search_bloc.dart';
import 'package:movie_explorer/features/search/search_view.dart';

/// Search tab entry point. It creates this screen's [SearchBloc] and wires
/// navigation; the [SearchView] does the rendering.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchBloc>(),
      child: SearchView(
        onMovieTap: (movie) => SearchMovieDetailsRoute(
          id: movie.id,
          $extra: movie,
        ).push<void>(context),
      ),
    );
  }
}
