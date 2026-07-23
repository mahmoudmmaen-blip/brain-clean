package com.brainclean.mobile

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process
import android.provider.Settings
import java.util.Calendar

/**
 * Reads foreground time for target social apps via [UsageStatsManager.queryEvents].
 *
 * Local-only: package → minutes maps stay on device (no network upload from this helper).
 *
 * Play v1: [PACKAGE_USAGE_STATS] is not declared in the manifest and the Flutter Home
 * card is gated off. Keep this helper for a later opt-in release with Play declaration
 * + in-app disclosure.
 *
 * We use event-based summation (MOVE_TO_FOREGROUND / MOVE_TO_BACKGROUND) instead of
 * [UsageStatsManager.queryUsageStats] because queryUsageStats returns coarse buckets
 * (often stale until the next interval) and can mis-attribute time when the device
 * was idle. queryEvents gives per-transition timestamps for accurate same-day totals.
 */
object UsageStatsHelper {
    const val CHANNEL_NAME = "com.brainclean.mobile/usage_stats"

    val TARGET_PACKAGES: Set<String> = setOf(
        "com.instagram.android",
        "com.zhiliaoapp.musically",
        "com.ss.android.ugc.trill",
        "com.snapchat.android",
        "com.facebook.katana",
        "com.twitter.android",
    )

    fun hasUsageAccess(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun openUsageAccessSettings(context: Context) {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun getTodaySocialMediaUsageMinutes(context: Context): Map<String, Long> {
        if (!hasUsageAccess(context)) {
            return emptyMap()
        }

        val usageStatsManager =
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val startMs = calendar.timeInMillis
        val endMs = System.currentTimeMillis()

        val totalsMs = mutableMapOf<String, Long>().apply {
            TARGET_PACKAGES.forEach { put(it, 0L) }
        }
        val lastForegroundMs = mutableMapOf<String, Long>()

        val events = usageStatsManager.queryEvents(startMs, endMs)
        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val packageName = event.packageName ?: continue
            if (!TARGET_PACKAGES.contains(packageName)) continue

            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND,
                UsageEvents.Event.ACTIVITY_RESUMED -> {
                    lastForegroundMs[packageName] = event.timeStamp
                }
                UsageEvents.Event.MOVE_TO_BACKGROUND,
                UsageEvents.Event.ACTIVITY_PAUSED -> {
                    val foregroundStart = lastForegroundMs.remove(packageName) ?: continue
                    totalsMs[packageName] =
                        totalsMs.getOrDefault(packageName, 0L) +
                            (event.timeStamp - foregroundStart)
                }
            }
        }

        // Apps still in foreground at query time.
        for ((packageName, foregroundStart) in lastForegroundMs) {
            totalsMs[packageName] =
                totalsMs.getOrDefault(packageName, 0L) + (endMs - foregroundStart)
        }

        return totalsMs
            .filterValues { it > 0L }
            .mapValues { (_, ms) -> ms / 60_000L }
    }
}
