package com.tatilsayaci.tatil_sayaci

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "tatil_sayaci/foreground_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startForegroundService" -> {
                    val args = call.arguments as? Map<String, Any?>
                    val intent = Intent(this, NotificationForegroundService::class.java).apply {
                        action = NotificationForegroundService.ACTION_START
                        putExtra(NotificationForegroundService.EXTRA_SUMMER_LABEL, args?.get("summerLabel") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_SUMMER_DAYS, args?.get("summerDays") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_SUMMER_VISIBLE, args?.get("summerVisible") as? Boolean ?: false)
                        putExtra(NotificationForegroundService.EXTRA_HOLIDAY_LABEL, args?.get("holidayLabel") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_HOLIDAY_DAYS, args?.get("holidayDays") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_HOLIDAY_VISIBLE, args?.get("holidayVisible") as? Boolean ?: false)
                        putExtra(NotificationForegroundService.EXTRA_CUSTOM_LABEL, args?.get("customLabel") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_CUSTOM_DAYS, args?.get("customDays") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_CUSTOM_VISIBLE, args?.get("customVisible") as? Boolean ?: false)
                        putExtra(NotificationForegroundService.EXTRA_EMPTY_VISIBLE, args?.get("emptyVisible") as? Boolean ?: false)
                    }
                    startForegroundService(intent)
                    result.success(null)
                }
                "updateForegroundService" -> {
                    val args = call.arguments as? Map<String, Any?>
                    val intent = Intent(this, NotificationForegroundService::class.java).apply {
                        action = NotificationForegroundService.ACTION_UPDATE
                        putExtra(NotificationForegroundService.EXTRA_SUMMER_LABEL, args?.get("summerLabel") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_SUMMER_DAYS, args?.get("summerDays") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_SUMMER_VISIBLE, args?.get("summerVisible") as? Boolean ?: false)
                        putExtra(NotificationForegroundService.EXTRA_HOLIDAY_LABEL, args?.get("holidayLabel") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_HOLIDAY_DAYS, args?.get("holidayDays") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_HOLIDAY_VISIBLE, args?.get("holidayVisible") as? Boolean ?: false)
                        putExtra(NotificationForegroundService.EXTRA_CUSTOM_LABEL, args?.get("customLabel") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_CUSTOM_DAYS, args?.get("customDays") as? String ?: "")
                        putExtra(NotificationForegroundService.EXTRA_CUSTOM_VISIBLE, args?.get("customVisible") as? Boolean ?: false)
                        putExtra(NotificationForegroundService.EXTRA_EMPTY_VISIBLE, args?.get("emptyVisible") as? Boolean ?: false)
                    }
                    startService(intent)
                    result.success(null)
                }
                "stopForegroundService" -> {
                    val intent = Intent(this, NotificationForegroundService::class.java).apply {
                        action = NotificationForegroundService.ACTION_STOP
                    }
                    startService(intent)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
