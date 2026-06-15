import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// Provides screen-lock capabilities via the Device Admin API on Android.
///
/// The user must enable Zen Assistant as a device admin in Settings
/// before [lockScreen] will work. Use [requestDeviceAdmin] to open
/// the system activation screen.
class LockService {
  LockService._();

  static const _channel = MethodChannel('com.example.jarvis_flutter/launcher');

  /// Lock the screen immediately.
  ///
  /// Returns `true` if the screen was locked, `false` if device admin
  /// is not active or the call failed.
  static Future<bool> lockScreen() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('lockScreen') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Whether Zen Assistant is an active device admin.
  static Future<bool> isDeviceAdmin() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isDeviceAdmin') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Open the system "Activate device admin" screen so the user can
  /// grant Zen Assistant the permission to lock the screen.
  static Future<void> requestDeviceAdmin() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('requestDeviceAdmin');
    } catch (e) {
      // silently fail — the user can always navigate manually
    }
  }
}
