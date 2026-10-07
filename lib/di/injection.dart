import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:movie_explorer/di/injection.config.dart';

/// The app's single service locator.
///
/// Only `main.dart`, the router and Page widgets resolve dependencies from it.
/// Everything else receives them through its constructor, so tests can pass
/// fakes directly without touching the container.
final GetIt getIt = GetIt.instance;

/// Composition root: the one place where concrete implementations are chosen
/// and wired together (the role of Hilt modules on Android and of
/// `AppEnvironment` on iOS).
///
/// `injectable` generates `getIt.init()` from the annotations it finds under
/// `lib/` (`@injectable`, `@lazySingleton`, `@module`…). It is async so that
/// dependencies needing async setup (`@preResolve`) can join later.
@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();
}
