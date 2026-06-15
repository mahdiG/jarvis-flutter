/// Represents an app entry on the Zen Launcher.
class LauncherApp {
  /// Display name shown to the user.
  final String name;

  /// Android package name (e.g. "com.android.chrome").
  final String packageName;

  /// Whether this app is in the user's favorites list.
  bool isFavorite;

  /// Position in the favorites list (0-based). -1 if not in favorites.
  int favoriteOrder;

  LauncherApp({
    required this.name,
    required this.packageName,
    this.isFavorite = false,
    this.favoriteOrder = -1,
  });

  /// Create a copy with optional field overrides.
  LauncherApp copyWith({
    String? name,
    String? packageName,
    bool? isFavorite,
    int? favoriteOrder,
  }) {
    return LauncherApp(
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      isFavorite: isFavorite ?? this.isFavorite,
      favoriteOrder: favoriteOrder ?? this.favoriteOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LauncherApp &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() =>
      'LauncherApp(name: $name, packageName: $packageName, isFavorite: $isFavorite)';
}