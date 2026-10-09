import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/di/injection.dart';
import 'package:movie_explorer/features/settings/settings_view.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Settings tab entry point.
///
/// Unlike the other Pages it provides no Cubit: settings are app-scoped, and
/// the `SettingsCubit` above `MaterialApp` is already in the tree. It only
/// supplies the version string from the platform's package info.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final info = getIt<PackageInfo>();
    return SettingsView(appVersion: '${info.version} (${info.buildNumber})');
  }
}
