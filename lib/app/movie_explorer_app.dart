import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/app/theme_mode_mapper.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/core/navigation/app_router.dart';
import 'package:movie_explorer/di/injection.dart';
import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/features/settings/cubit/settings_cubit.dart';

/// The root widget: app-scoped state, themes and the router.
///
/// - The [SettingsCubit] is provided *above* [MaterialApp.router], so every
///   route can read it, and it lives as long as the app.
/// - A `BlocSelector` rebuilds `MaterialApp` only when the theme mode changes,
///   not on every settings change.
/// - The [GoRouter] is created once and disposed with this widget.
class MovieExplorerApp extends StatefulWidget {
  const MovieExplorerApp({super.key});

  @override
  State<MovieExplorerApp> createState() => _MovieExplorerAppState();
}

class _MovieExplorerAppState extends State<MovieExplorerApp> {
  late final GoRouter _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>(),
      child: BlocSelector<SettingsCubit, AppSettings, AppThemeMode>(
        selector: (settings) => settings.themeMode,
        builder: (context, themeMode) => MaterialApp.router(
          title: 'MovieExplorer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode.toThemeMode(),
          routerConfig: _router,
        ),
      ),
    );
  }
}
