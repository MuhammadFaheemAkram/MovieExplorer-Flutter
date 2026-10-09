import 'dart:convert';

import 'package:drift/drift.dart';

/// Stores a `List<String>` in a single TEXT column as a JSON array.
///
/// SQLite has no list type. JSON avoids the escaping bugs of a delimiter such
/// as `|` (the Android edition's choice), and drift applies the converter both
/// ways, so the rest of the app only ever sees a `List<String>`.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<Object?>).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
