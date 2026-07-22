package com.brainclean.mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UsageStatsHelper.CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsageAccess" -> {
                    result.success(UsageStatsHelper.hasUsageAccess(this))
                }
                "openUsageAccessSettings" -> {
                    UsageStatsHelper.openUsageAccessSettings(this)
                    result.success(null)
                }
                "getTodaySocialMediaUsage" -> {
                    val usage = UsageStatsHelper.getTodaySocialMediaUsageMinutes(this)
                    result.success(usage)
                }
                else -> result.notImplemented()
            }
        }
    }
}
