import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/navigation/app_routes.dart';
import 'package:movie_explorer/di/injection.dart';
import 'package:movie_explorer/features/home/cubit/home_cubit.dart';
import 'package:movie_explorer/features/home/home_view.dart';

/// Home tab entry point. It creates this screen's [HomeCubit], starts the first
/// load and wires navigation. The [HomeView] does the rendering.
///
/// `BlocProvider` owns the Cubit: it is created when the page first builds and
/// closed when the page leaves the tree.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..load(),
      child: HomeView(
        onMovieTap: (movie) =>
            HomeMovieDetailsRoute(id: movie.id).push<void>(context),
      ),
    );
  }
}
