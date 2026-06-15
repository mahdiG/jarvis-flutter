import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/launcher_app.dart';

/// Persists the user's favorite app selections across restarts.
///
/// Uses [SharedPreferences] to store a JSON-encoded list of favorite apps
/// keyed by package name, so the data survives device reboots.
class FavoritesService {
  FavoritesService._();

  static const _key = 'favorite_apps';

  /// Persist the current favorite list to disk.
  static Future<void> saveFavorites(List<LauncherApp> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = favorites
        .map((favoriteApp) => jsonEncode({
              'name': favoriteApp.name,
              'packageName': favoriteApp.packageName,
              'favoriteOrder': favoriteApp.favoriteOrder,
            }))
        .toList();
    await prefs.setStringList(_key, encoded);
  }

  /// Load persisted favorites, merging in [defaults] if nothing was saved yet.
  ///
  /// On the very first launch (no saved data) the provided defaults are used.
  static Future<List<LauncherApp>> loadWithDefaults({
    required List<LauncherApp> defaults,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? stored;
    try {
      stored = prefs.getStringList(_key);
    } catch (_) {
      // Old data was stored as a single string (legacy format).
      // Clear it so we seed fresh defaults below.
      await prefs.remove(_key);
    }

    if (stored == null || stored.isEmpty) {
      // First launch — seed with defaults and persist immediately.
      final seeded = defaults
          .map((defaultApp) => defaultApp.copyWith(
                isFavorite: true,
                favoriteOrder: defaultApp.favoriteOrder,
              ))
          .toList();
      await saveFavorites(seeded);
      return seeded;
    }

    return stored.map((jsonStr) {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return LauncherApp(
        name: decoded['name'] as String? ?? 'Unknown',
        packageName: decoded['packageName'] as String? ?? '',
        isFavorite: true,
        favoriteOrder: decoded['favoriteOrder'] as int? ?? 0,
      );
    }).toList();
  }
}