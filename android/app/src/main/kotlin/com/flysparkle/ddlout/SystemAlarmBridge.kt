package com.flysparkle.ddlout

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.provider.AlarmClock
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.Calendar
import java.util.UUID

/** Clock owns the alarms; our persisted list is an export journal, not a mirror. */
class SystemAlarmBridge(private val activity: Activity) {
    companion object { const val REQUEST_CODE = 5404 }
    private val preferences = activity.getSharedPreferences("clock_exports_v1", Context.MODE_PRIVATE)
    private var pending: MethodChannel.Result? = null
    private var intents = emptyList<Pair<String, Intent>>()
    private var submitted = 0
    private var waitingForClock = false

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "list" -> {
                    result.success(preferences.all.values.mapNotNull { value ->
                        try {
                            val entry = JSONObject(value as String)
                            mapOf("id" to entry.getString("id"), "title" to entry.getString("title"),
                                "notes" to entry.getString("notes"), "time" to entry.getLong("time"),
                                "weekly" to entry.getBoolean("weekly"), "enabled" to true)
                        } catch (_: Exception) { null }
                    }); return
                }
                "forget" -> {
                    val id = call.argument<String>("id") ?: throw IllegalArgumentException("Missing record ID")
                    if (!preferences.edit().remove(id).commit()) throw IllegalStateException("Cannot save alarm records")
                    result.success(null); return
                }
                "openClock" -> {
                    activity.startActivity(Intent(AlarmClock.ACTION_SHOW_ALARMS))
                    result.success(null); return
                }
                "schedule" -> schedule(call, result)
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error("clock_unavailable", error.message ?: "Clock operation failed.", null)
        }
    }

    private fun schedule(call: MethodCall, result: MethodChannel.Result) {
        if (pending != null) { result.error("busy", "A clock export is in progress.", null); return }
        val title = call.argument<String>("title")?.trim().orEmpty()
        val notes = call.argument<String>("notes")?.trim().orEmpty()
        val rawTimes = call.argument<List<Number>>("times")
        if (title.isEmpty() || title.length > 200 || notes.length > 1000 || rawTimes.isNullOrEmpty() || rawTimes.size > 100) {
            result.error("invalid_arguments", "Invalid alarm information.", null); return
        }
        val now = System.currentTimeMillis()
        val times = rawTimes.map { it.toLong() }.distinct().sorted()
        if (times.any { it <= now || it > 253402300799000L }) {
            result.error("past_time", "Alarm times must be valid future timestamps.", null); return
        }
        if (Intent(AlarmClock.ACTION_SET_ALARM).resolveActivity(activity.packageManager) == null) {
            result.error("clock_unavailable", "No clock application is available.", null); return
        }
        intents = times.map { time ->
            val local = Calendar.getInstance().apply { timeInMillis = time }
            val next = Calendar.getInstance().apply {
                timeInMillis = now
                set(Calendar.HOUR_OF_DAY, local.get(Calendar.HOUR_OF_DAY))
                set(Calendar.MINUTE, local.get(Calendar.MINUTE))
                set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
                if (timeInMillis <= now) add(Calendar.DAY_OF_MONTH, 1)
            }
            val weekly = next.timeInMillis != time
            val id = UUID.randomUUID().toString()
            val record = JSONObject().put("id", id).put("title", title).put("notes", notes)
                .put("time", time).put("weekly", weekly).toString()
            record to Intent(AlarmClock.ACTION_SET_ALARM).apply {
                putExtra(AlarmClock.EXTRA_HOUR, local.get(Calendar.HOUR_OF_DAY))
                putExtra(AlarmClock.EXTRA_MINUTES, local.get(Calendar.MINUTE))
                putExtra(AlarmClock.EXTRA_MESSAGE, "$title [DDL:${id.take(8)}]" + if (notes.isEmpty()) "" else "\n$notes")
                if (weekly) putIntegerArrayListExtra(AlarmClock.EXTRA_DAYS, arrayListOf(local.get(Calendar.DAY_OF_WEEK)))
                // Keep Clock visible so the user can confirm a recurring alarm.
                putExtra(AlarmClock.EXTRA_SKIP_UI, false)
            }
        }
        submitted = 0
        waitingForClock = false
        pending = result
        launchNext()
    }

    fun onActivityResult(requestCode: Int) {
        if (requestCode != REQUEST_CODE || !waitingForClock) return
        waitingForClock = false
        // No standard success result exists for ACTION_SET_ALARM.
        activity.window.decorView.post { launchNext() }
    }

    fun onResume() {
        if (pending != null && !waitingForClock) activity.window.decorView.post { launchNext() }
    }

    @Suppress("DEPRECATION")
    private fun launchNext() {
        val result = pending ?: return
        if (waitingForClock) return
        if (submitted >= intents.size) {
            pending = null; intents = emptyList(); result.success(submitted); return
        }
        val (record, intent) = intents[submitted]
        val id = JSONObject(record).getString("id")
        try {
            // Persist before leaving; Android may destroy DDL out! while Clock is open.
            if (!preferences.edit().putString(id, record).commit()) throw IllegalStateException("Cannot save alarm records")
            waitingForClock = true
            activity.startActivityForResult(intent, REQUEST_CODE)
            submitted++
        } catch (error: Exception) {
            preferences.edit().remove(id).commit()
            waitingForClock = false; pending = null; intents = emptyList()
            result.error("clock_unavailable", error.message ?: "Unable to open Clock.", submitted)
        }
    }

    fun dispose() {
        pending?.error("interrupted", "Clock export was interrupted; check the export list.", submitted)
        pending = null
    }
}
