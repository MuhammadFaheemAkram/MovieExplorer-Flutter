import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Registers objects that can't carry injectable annotations themselves:
/// Flutter and third-party types (the equivalent of a Hilt `@Module`).
@module
abstract class AppModule {
  /// The real asset bundle. Tests build their own `AssetJsonLoader` with a
  /// fake bundle instead.
  @lazySingleton
  AssetBundle get assetBundle => rootBundle;
}
