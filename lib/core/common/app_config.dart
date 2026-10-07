/// Compile-time switches for the fake backend.
abstract final class AppConfig {
  /// Flip to `true` to make every fake API call fail, and walk through each
  /// screen's error state end to end.
  static const bool simulateNetworkErrors = false;
}
