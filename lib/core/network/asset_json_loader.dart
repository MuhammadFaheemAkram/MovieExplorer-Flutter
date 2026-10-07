import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Reads JSON files that ship inside the app bundle.
///
/// Wraps Flutter's [AssetBundle] so the fake API depends on one small class,
/// not on the global `rootBundle`. Tests construct it with a fake bundle.
@lazySingleton
class AssetJsonLoader {
  const AssetJsonLoader(this._bundle);

  final AssetBundle _bundle;

  /// Loads [path] and decodes it as a JSON array of objects.
  ///
  /// Throws a [FormatException] if the file isn't valid JSON or isn't an array
  /// of objects.
  Future<List<Map<String, dynamic>>> loadObjectList(String path) async {
    final raw = await _bundle.loadString(path);
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List<Object?> ||
        decoded.any((item) => item is! Map<String, dynamic>)) {
      throw FormatException('Expected a JSON array of objects in $path');
    }
    return decoded.cast<Map<String, dynamic>>();
  }
}
