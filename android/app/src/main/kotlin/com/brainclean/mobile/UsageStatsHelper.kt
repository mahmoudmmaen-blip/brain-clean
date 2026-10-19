package com.brainclean.mobile

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Process
import android.provider.Settings
import java.util.Calendar
import java.util.Locale
import java.util.concurrent.TimeUnit

object UsageStatsHelper {
    const val CHANNEL_NAME = "brainclean/usage"

    fun hasAccess(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun openSettings(context: Context): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Last [days] local calendar days of foreground time in minutes,
     * excluding this app and the default home launcher.
     */
    fun dailyTotals(context: Context, days: Int): List<Map<String, Any>> {
        val safeDays = days.coerceIn(1, 60)
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val end = System.currentTimeMillis()
        val startCal = Calendar.getInstance().apply {
            timeInMillis = end
            add(Calendar.DAY_OF_YEAR, -(safeDays - 1))
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val start = startCal.timeInMillis

        val exclude = HashSet<String>()
        exclude.add(context.packageName)
        defaultLauncherPackage(context)?.let { exclude.add(it) }

        val events = usm.queryEvents(start, end)
        val event = UsageEvents.Event()
        val resumeAt = HashMap<String, Long>()
        val minutesByDay = HashMap<String, Long>()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName ?: continue
            if (exclude.contains(pkg)) continue
            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED,
                UsageEvents.Event.MOVE_TO_FOREGROUND,
                -> {
                    resumeAt[pkg] = event.timeStamp
                }
                UsageEvents.Event.ACTIVITY_PAUSED,
                UsageEvents.Event.MOVE_TO_BACKGROUND,
                -> {
                    val resumed = resumeAt.remove(pkg) ?: continue
                    var from = resumed.coerceAtLeast(start)
                    val to = event.timeStamp.coerceAtMost(end)
                    if (to <= from) continue
                    accumulateForeground(minutesByDay, from, to)
                }
            }
        }

        // Close open sessions at [end].
        for ((_, resumed) in resumeAt) {
            var from = resumed.coerceAtLeast(start)
            if (end > from) {
                accumulateForeground(minutesByDay, from, end)
            }
        }

        val out = ArrayList<Map<String, Any>>(safeDays)
        val cursor = Calendar.getInstance().apply {
            timeInMillis = start
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        repeat(safeDays) {
            val key = dayKey(cursor)
            val minutes = ((minutesByDay[key] ?: 0L) / TimeUnit.MINUTES.toMillis(1))
                .coerceAtMost(24L * 60L)
            out.add(
                mapOf(
                    "date" to key,
                    "minutes" to minutes.toInt(),
                ),
            )
            cursor.add(Calendar.DAY_OF_YEAR, 1)
        }
        return out
    }

    private fun accumulateForeground(
        minutesByDay: HashMap<String, Long>,
        fromMs: Long,
        toMs: Long,
    ) {
        var cursor = fromMs
        while (cursor < toMs) {
            val cal = Calendar.getInstance().apply { timeInMillis = cursor }
            val dayEnd = Calendar.getInstance().apply {
                timeInMillis = cursor
                set(Calendar.HOUR_OF_DAY, 23)
                set(Calendar.MINUTE, 59)
                set(Calendar.SECOND, 59)
                set(Calendar.MILLISECOND, 999)
            }.timeInMillis + 1
            val sliceEnd = minOf(toMs, dayEnd)
            val key = dayKey(cal)
            minutesByDay[key] = (minutesByDay[key] ?: 0L) + (sliceEnd - cursor)
            cursor = sliceEnd
        }
    }

    private fun dayKey(cal: Calendar): String {
        return String.format(
            Locale.US,
            "%04d-%02d-%02d",
            cal.get(Calendar.YEAR),
            cal.get(Calendar.MONTH) + 1,
            cal.get(Calendar.DAY_OF_MONTH),
        )
    }

    private fun defaultLauncherPackage(context: Context): String? {
        return try {
            val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
            val resolved = context.packageManager.resolveActivity(
                intent,
                PackageManager.MATCH_DEFAULT_ONLY,
            )
            resolved?.activityInfo?.packageName
        } catch (_: Exception) {
            null
        }
    }
}
