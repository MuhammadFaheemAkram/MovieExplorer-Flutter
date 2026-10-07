import 'package:material_ui/material_ui.dart';
import 'package:movie_explorer/app/movie_explorer_app.dart';
import 'package:movie_explorer/di/injection.dart';

Future<void> main() async {
  // Bindings must exist before any async setup touches plugins or assets.
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MovieExplorerApp());
}
