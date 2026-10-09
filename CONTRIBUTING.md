# Contributing to MovieExplorer (Flutter)

Thanks for your interest! MovieExplorer is a learning-focused reference project, so contributions that improve clarity, correctness or teaching value are especially welcome.

## Ground Rules

- Be respectful. See the [Code of Conduct](CODE_OF_CONDUCT.md).
- **Keep the architecture intact**
  - Respect the layer boundaries: View → Cubit/Bloc → UseCase → Repository → data source.
  - `domain/` stays pure Dart.
  - drift files never import `material_ui`.
- **UI:** import `package:material_ui/material_ui.dart`, never `package:flutter/material.dart`.
- **Dependencies:** keep them few and mainstream, and explain each new one in the README.

## Development Setup

- Install [FVM](https://fvm.app), then run `fvm install`. It reads `.fvmrc`, which pins Flutter 3.47.6.
- iOS needs Xcode. Android needs the Android SDK and Java 17+ (Android Studio's bundled JDK works).
- Get the packages with `fvm flutter pub get`, then start the app with `fvm flutter run`.
- After changing annotated code (freezed, json_serializable, injectable, drift, typed routes), regenerate it:

  ```bash
  fvm dart run build_runner build
  ```

  Generated files are committed, and CI fails if they are stale.

## Coding Conventions

- **Lints:** `fvm flutter analyze` must report **no issues**. The rules are `flutter_lints` plus strict casts, inference and raw types.
- **Formatting:** `fvm dart format .` (the tall style).
- **Pages and Views:** Pages create and provide a Cubit/Bloc and wire navigation. Views render state and forward intents.
- **Cubit or Bloc:** use a Cubit by default. Use a Bloc only when event transformers (debounce, cancellation) earn their place.
- **Immutable state:** freezed sealed unions, rendered with an exhaustive `switch`.
- **Comments** explain *architecture decisions*, not obvious code.

## Commits

This project uses **[Conventional Commits](https://www.conventionalcommits.org/)**:

```
<type>(<scope>): <message>
```

Examples: `feat(home): implement trending grid`, `test(search): add debounce tests`, `docs(project): update architecture notes`.

## Pull Requests

1. Fork the repository and create a topic branch.
2. Make sure `fvm flutter analyze`, `fvm dart format --set-exit-if-changed .` and `fvm flutter test` all pass.
3. Update or add documentation where relevant.
4. Open a PR with a clear description of the change and its motivation.

## Tests

- **Cubits/Blocs:** `bloc_test`.
- **Views:** widget tests with `MockCubit` / `MockBloc` from `bloc_test` and `mocktail`.
- **Data:** hand-written fakes for repositories.
- **drift:** `NativeDatabase.memory()`.
- **Preferences:** `InMemorySharedPreferencesAsync`.
- **Every async wait must be bounded.** See [docs/TESTING.md](docs/TESTING.md).
