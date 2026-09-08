package com.flysparkle.ddlout

import android.app.Activity
import android.content.Intent
import android.provider.AlarmClock
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

/** Exports clock intents in order, waiting for each clock activity to finish. */
class SystemAlarmBridge(private val activity: Activity) {
    companion object { const val REQUEST_CODE = 5404 }
    private var pending: MethodChannel.Result? = null
    private var intents = emptyList<Intent>()
    private var submitted = 0
    private var waitingForClock = false

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "schedule") { result.notImplemented(); return }
        if (pending != null) { result.error("busy", "A clock export is in progress.", null); return }
        val title = call.argument<String>("title")?.trim().orEmpty()
        val notes = call.argument<String>("notes")?.trim().orEmpty()
        val rawTimes = call.argument<List<Number>>("times")
        if (title.isEmpty() || title.length > 200 || notes.length > 1000 || rawTimes.isNullOrEmpty() || rawTimes.size > 100) {
            result.error("invalid_arguments", "Invalid alarm information.", null); return
        }
        val now = System.currentTimeMillis()
        val times = rawTimes.map { it.toLong() }.distinct().sorted()
        val clockIntent = Intent(AlarmClock.ACTION_SET_ALARM)
        val component = clockIntent.resolveActivity(activity.packageManager)
        if (component == null) { result.error("clock_unavailable", "No clock application is available.", null); return }
        for (time in times) {
            if (time <= now) { result.error("past_time", "Alarm times must be in the future.", null); return }
            val requested = Calendar.getInstance().apply { timeInMillis = time }
            val next = Calendar.getInstance().apply {
                timeInMillis = now
                set(Calendar.HOUR_OF_DAY, requested.get(Calendar.HOUR_OF_DAY))
                set(Calendar.MINUTE, requested.get(Calendar.MINUTE))
                set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
                if (timeInMillis <= now) add(Calendar.DAY_OF_MONTH, 1)
            }
            if (next.timeInMillis != time) {
                result.error("date_unsupported", "The clock interface cannot represent this calendar date.", null); return
            }
        }
        intents = times.map { time ->
            val local = Calendar.getInstance().apply { timeInMillis = time }
            Intent(AlarmClock.ACTION_SET_ALARM).apply {
                // Leave the default clock choice to Android's resolver when needed.
                putExtra(AlarmClock.EXTRA_HOUR, local.get(Calendar.HOUR_OF_DAY))
                putExtra(AlarmClock.EXTRA_MINUTES, local.get(Calendar.MINUTE))
                putExtra(AlarmClock.EXTRA_MESSAGE, if (notes.isEmpty()) title else "$title\n$notes")
                putExtra(AlarmClock.EXTRA_SKIP_UI, true)
            }
        }
        submitted = 0
        waitingForClock = false
        pending = result
        launchNext()
    }

    fun onActivityResult(requestCode: Int) {
        if (requestCode != REQUEST_CODE || !waitingForClock) return
        // Android defines no success result for this intent. Report submissions,
        // never pretend this is a receipt proving the clock saved an alarm.
        submitted++
        waitingForClock = false
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
        try {
            waitingForClock = true
            activity.startActivityForResult(intents[submitted], REQUEST_CODE)
        } catch (error: Exception) {
            waitingForClock = false; pending = null; intents = emptyList()
            result.error("clock_unavailable", "Unable to open the clock application.", submitted)
        }
    }

    fun dispose() {
        pending?.error("interrupted", "Clock export was interrupted.", submitted)
        pending = null
    }
}
