/// The app's error vocabulary.
///
/// Every failure that can reach the UI is one of these types, and each carries
/// a user-facing [message]. Screens therefore render a small, stable set of
/// error states instead of raw exceptions. The messages match the iOS
/// edition's `AppError` so both apps speak the same language.
///
/// `sealed` lets the compiler check that a `switch` over an [AppException]
/// handles every subtype.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Copy that is safe to show to the user.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The (fake) network call failed.
final class NetworkException extends AppException {
  const NetworkException()
    : super(
        'Something went wrong while loading. Check your connection and try '
        'again.',
      );
}

/// The requested item does not exist.
final class NotFoundException extends AppException {
  const NotFoundException()
    : super("We couldn't find what you were looking for.");
}

/// The data could not be decoded (malformed JSON or unexpected types).
final class DataFormatException extends AppException {
  const DataFormatException()
    : super("We couldn't read the data. Please try again.");
}

/// Anything unexpected that isn't one of the cases above.
final class UnknownException extends AppException {
  const UnknownException()
    : super('An unexpected error occurred. Please try again.');
}
