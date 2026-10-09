import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';
import 'package:movie_explorer/domain/model/app_settings.dart';
import 'package:movie_explorer/domain/model/app_theme_mode.dart';
import 'package:movie_explorer/domain/model/content_language.dart';
import 'package:movie_explorer/features/settings/cubit/settings_cubit.dart';

/// Renders the settings: appearance, content language and About.
///
/// It reads the *app-scoped* [SettingsCubit] from above `MaterialApp`, so
/// choosing Dark here restyles the whole app instantly.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.appVersion});

  /// For example `1.0.0 (1)`.
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
            children: [
              const _SectionHeader('Appearance'),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium,
                ),
                child: SegmentedButton<AppThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selection) =>
                      cubit.selectThemeMode(selection.single),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              const _SectionHeader('Content language'),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium,
                ),
                child: DropdownMenu<ContentLanguage>(
                  // Rebuilt when the value changes elsewhere: DropdownMenu only
                  // reads `initialSelection` once.
                  key: ValueKey(settings.language),
                  initialSelection: settings.language,
                  expandedInsets: EdgeInsets.zero,
                  label: const Text('Language'),
                  leadingIcon: const Icon(Icons.translate),
                  helperText: 'Shown as a label on Home; no translations yet.',
                  dropdownMenuEntries: [
                    for (final language in ContentLanguage.values)
                      DropdownMenuEntry(
                        value: language,
                        label: language.displayName,
                      ),
                  ],
                  onSelected: (language) {
                    if (language != null) cubit.selectLanguage(language);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              const _SectionHeader('About'),
              ListTile(
                leading: const Icon(Icons.movie_outlined),
                title: const Text('MovieExplorer'),
                subtitle: Text('Version $appVersion'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium,
                ),
                child: Text(
                  'A learning-focused Flutter app: clean architecture, Bloc, '
                  'drift and go_router, with a fake API.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              AboutListTile(
                icon: const Icon(Icons.info_outline),
                applicationName: 'MovieExplorer',
                applicationVersion: appVersion,
                applicationLegalese: '© 2026 BitFuse · MIT License',
                child: const Text('Licenses'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.small,
        AppSpacing.medium,
        AppSpacing.xSmall,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
