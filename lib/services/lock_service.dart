import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// Provides screen-lock capabilities via an Android AccessibilityService.
///
/// The user must enable "Zen Assistant" in Settings → Accessibility
/// before [lockScreen] will work. Use [requestEnableService] to open
/// the system accessibility settings screen.
class LockService {
  LockService._();

  static const _channel = MethodChannel('com.example.jarvis_flutter/launcher');

  /// Lock the screen immediately via [GLOBAL_ACTION_LOCK_SCREEN].
  ///
  /// Returns `true` if the screen was locked, `false` if the
  /// accessibility service is not running or the call failed.
  static Future<bool> lockScreen() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('lockScreen') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Whether the Zen Assistant accessibility service is currently running.
  static Future<bool> isServiceRunning() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isServiceRunning') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Open the system Accessibility settings so the user can enable
  /// the Zen Assistant accessibility service.
  static Future<void> requestEnableService() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('requestEnableService');
    } catch (e) {
      // silently fail — the user can always navigate manually
    }
  }
}
