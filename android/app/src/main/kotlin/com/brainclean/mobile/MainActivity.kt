package com.brainclean.mobile

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Edge-to-edge: Flutter draws behind system bars; Dart/SafeArea insets content.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ExternalLinkHelper.CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openUri" -> {
                    val uri = call.argument<String>("uri")
                    if (uri.isNullOrBlank()) {
                        result.error("invalid_args", "uri is required", null)
                    } else {
                        result.success(ExternalLinkHelper.openUri(this, uri))
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UsageStatsHelper.CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasAccess" -> result.success(UsageStatsHelper.hasAccess(this))
                "openSettings" -> result.success(UsageStatsHelper.openSettings(this))
                "dailyTotals" -> {
                    val days = call.argument<Int>("days") ?: 30
                    try {
                        result.success(UsageStatsHelper.dailyTotals(this, days))
                    } catch (e: Exception) {
                        result.error("usage_failed", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
