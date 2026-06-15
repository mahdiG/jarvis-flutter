package com.example.jarvis_flutter

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.example.jarvis_flutter/launcher"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledApps" -> {
                        val apps = getInstalledApps()
                        result.success(apps)
                    }
                    "launchApp" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            val success = launchApp(packageName)
                            result.success(success)
                        } else {
                            result.error("INVALID_ARG", "packageName required", null)
                        }
                    }
                    "lockScreen" -> {
                        val success = lockScreen()
                        result.success(success)
                    }
                    "isDeviceAdmin" -> {
                        result.success(isDeviceAdmin())
                    }
                    "requestDeviceAdmin" -> {
                        requestDeviceAdmin()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Queries the PackageManager for all installed apps that have a
     * launcher intent filter and returns them as a list of maps.
     */
    private fun getInstalledApps(): List<Map<String, String>> {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfoList = packageManager.queryIntentActivities(intent, 0)

        return resolveInfoList
            .map { resolveInfo ->
                val activityInfo = resolveInfo.activityInfo
                mapOf(
                    "name" to (activityInfo.loadLabel(packageManager).toString()),
                    "packageName" to activityInfo.packageName,
                )
            }
            .sortedBy { it["name"]?.lowercase() }
    }

    /**
     * Lock the screen via DevicePolicyManager.
     *
     * Only works if the app is an active device admin.
     * Returns true if the screen was locked, false otherwise.
     */
    private fun lockScreen(): Boolean {
        return try {
            val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val componentName = ComponentName(this, AdminReceiver::class.java)
            if (dpm.isAdminActive(componentName)) {
                dpm.lockNow()
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Whether this app is an active device admin.
     */
    private fun isDeviceAdmin(): Boolean {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val componentName = ComponentName(this, AdminReceiver::class.java)
        return dpm.isAdminActive(componentName)
    }

    /**
     * Open the system "Activate device admin" screen so the user can
     * grant this app device admin permission.
     */
    private fun requestDeviceAdmin() {
        val componentName = ComponentName(this, AdminReceiver::class.java)
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
            putExtra(
                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "Zen Assistant needs device admin permission to lock the screen when you double-tap on the launcher."
            )
        }
        startActivity(intent)
    }

    /**
     * Launches an app by its package name.
     *
     * Returns true if the launch intent was resolved and sent, false otherwise.
     */
    private fun launchApp(packageName: String): Boolean {
        return try {
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                startActivity(launchIntent)
                true
            } else {
                // Fallback: open the app's settings page or Google Play.
                val fallbackIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                }
                startActivity(fallbackIntent)
                true
            }
        } catch (e: Exception) {
            false
        }
    }
}