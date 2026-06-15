/// Central configuration for the Zen Assistant app.
///
/// Feature flags can be overridden via `--dart-define` at build time.
/// For example:
///   flutter run --dart-define=LAUNCHER_ENABLED=false
class Config {
  Config._();

  /// Whether the Zen Launcher (Android home screen) is enabled.
  ///
  /// Set to `false` to remove the launcher from production builds that
  /// don't need it (e.g. web, iOS, linux). Defaults to `true` so it
  /// works out of the box in debug mode.
  static bool get launcherEnabled {
    // In production, we'll read from dart-define:
    //   --dart-define=LAUNCHER_ENABLED=false
    // For now, keep enabled so the launcher is visible during development.
    const fromDefine = String.fromEnvironment('LAUNCHER_ENABLED');
    if (fromDefine.isNotEmpty) {
      return fromDefine == 'true';
    }
    return true;
  }

  /// The maximum number of favorite apps shown on the launcher home.
  static const int maxFavoriteApps = 12;
}