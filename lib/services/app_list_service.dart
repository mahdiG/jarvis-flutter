import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import '../models/launcher_app.dart';

/// Provides the list of installed apps for the launcher.
///
/// On Android, uses a [MethodChannel] to query installed packages.
/// On other platforms (web, Linux, macOS, Windows), returns a curated
/// set of static mock apps so the UI remains viewable and doesn't crash.
class AppListService {
  AppListService._();

  static const _channel = MethodChannel('com.example.jarvis_flutter/launcher');

  /// Default favorite apps shown on first launch.
  static final List<LauncherApp> _defaultFavorites = [
    LauncherApp(
      name: 'Settings',
      packageName: 'com.android.settings',
      isFavorite: true,
      favoriteOrder: 0,
    ),
    LauncherApp(
      name: 'Photos',
      packageName: 'com.google.android.apps.photos',
      isFavorite: true,
      favoriteOrder: 1,
    ),
    LauncherApp(
      name: 'Mail',
      packageName: 'com.google.android.gm',
      isFavorite: true,
      favoriteOrder: 2,
    ),
    LauncherApp(
      name: 'Browser',
      packageName: 'com.android.chrome',
      isFavorite: true,
      favoriteOrder: 3,
    ),
    LauncherApp(
      name: 'Audio',
      packageName: 'com.google.android.apps.youtube.music',
      isFavorite: true,
      favoriteOrder: 4,
    ),
    LauncherApp(
      name: 'Maps',
      packageName: 'com.google.android.apps.maps',
      isFavorite: true,
      favoriteOrder: 5,
    ),
  ];

  /// Mock apps shown on non-Android platforms so the UI is visible.
  static final List<LauncherApp> _mockApps = [
    ..._defaultFavorites,
    LauncherApp(name: 'Calendar', packageName: 'mock.calendar'),
    LauncherApp(name: 'Clock', packageName: 'mock.clock'),
    LauncherApp(name: 'Calculator', packageName: 'mock.calculator'),
    LauncherApp(name: 'Notes', packageName: 'mock.notes'),
    LauncherApp(name: 'Files', packageName: 'mock.files'),
    LauncherApp(name: 'Weather', packageName: 'mock.weather'),
    LauncherApp(name: 'Camera', packageName: 'mock.camera'),
    LauncherApp(name: 'Contacts', packageName: 'mock.contacts'),
    LauncherApp(name: 'Phone', packageName: 'mock.phone'),
    LauncherApp(name: 'Messages', packageName: 'mock.messages'),
  ];

  /// Fetch all installed apps.
  ///
  /// On Android this queries the platform. On other platforms it returns
  /// a static curated list to keep the UI functional during development.
  static Future<List<LauncherApp>> fetchInstalledApps() async {
    if (!Platform.isAndroid) {
      return _mockApps.map((app) => app.copyWith()).toList();
    }

    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result == null) return [];

      return result
          .map((entry) {
            final appData = entry as Map<dynamic, dynamic>;
            return LauncherApp(
              name: appData['name'] as String? ?? 'Unknown',
              packageName: appData['packageName'] as String? ?? '',
            );
          })
          .where((app) => app.packageName.isNotEmpty)
          .toList();
    } catch (e) {
      // Fallback: return default list if the platform channel isn't set up.
      return _mockApps.map((app) => app.copyWith()).toList();
    }
  }

  /// Launch an app by its package name.
  static Future<bool> launchApp(String packageName) async {
    if (!Platform.isAndroid) {
      // Non-Android: no-op, just return true for UI feedback.
      return true;
    }

    try {
      final result = await _channel.invokeMethod<bool>('launchApp', {
        'packageName': packageName,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Returns the default favorites list (used on first run).
  static List<LauncherApp> get defaultFavorites {
    return _defaultFavorites
        .map((app) => app.copyWith())
        .toList();
  }
}