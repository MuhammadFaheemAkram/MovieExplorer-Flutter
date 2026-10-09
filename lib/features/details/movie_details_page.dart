import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/di/injection.dart';
import 'package:movie_explorer/domain/model/movie.dart';
import 'package:movie_explorer/features/details/cubit/movie_details_cubit.dart';
import 'package:movie_explorer/features/details/movie_details_view.dart';

/// Movie details, pushed inside whichever tab opened it.
///
/// The route passes only the id, plus the list's copy of the movie as an
/// optional [preview]. The Cubit loads the full details itself. Passing an id
/// rather than a whole object keeps routes deep-linkable and the data fresh.
class MovieDetailsPage extends StatelessWidget {
  const MovieDetailsPage({super.key, required this.movieId, this.preview});

  final int movieId;
  final Movie? preview;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<MovieDetailsCubit>(param1: movieId, param2: preview)..load(),
      child: const MovieDetailsView(),
    );
  }
}
