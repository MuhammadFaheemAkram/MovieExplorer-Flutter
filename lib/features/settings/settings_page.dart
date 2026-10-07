import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/core/design_system/design_system.dart';

/// Settings tab. Phase 1 placeholder; Phase 4 adds appearance, content
/// language and About.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const EmptyStateView(
        icon: Icons.settings_outlined,
        title: 'Settings',
        message: 'Coming in Phase 4: appearance, content language and About.',
      ),
    );
  }
}
