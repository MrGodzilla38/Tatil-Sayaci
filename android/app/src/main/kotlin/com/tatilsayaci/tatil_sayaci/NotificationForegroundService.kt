package com.tatilsayaci.tatil_sayaci

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat

class NotificationForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "tatil_sayaci_foreground"
        const val NOTIFICATION_ID = 1
        const val ACTION_START = "com.tatilsayaci.tatil_sayaci.START"
        const val ACTION_UPDATE = "com.tatilsayaci.tatil_sayaci.UPDATE"
        const val ACTION_STOP = "com.tatilsayaci.tatil_sayaci.STOP"

        const val EXTRA_SUMMER_LABEL = "summer_label"
        const val EXTRA_SUMMER_DAYS = "summer_days"
        const val EXTRA_SUMMER_VISIBLE = "summer_visible"

        const val EXTRA_HOLIDAY_LABEL = "holiday_label"
        const val EXTRA_HOLIDAY_DAYS = "holiday_days"
        const val EXTRA_HOLIDAY_VISIBLE = "holiday_visible"

        const val EXTRA_CUSTOM_LABEL = "custom_label"
        const val EXTRA_CUSTOM_DAYS = "custom_days"
        const val EXTRA_CUSTOM_VISIBLE = "custom_visible"

        const val EXTRA_EMPTY_VISIBLE = "empty_visible"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START, ACTION_UPDATE -> {
                val notification = createNotification(intent)
                startForeground(NOTIFICATION_ID, notification)
            }
            ACTION_STOP -> {
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Tatil Sayacı Bildirimleri",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Tatil geri sayım bildirimleri"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(intent: Intent?): Notification {
        val remoteViews = RemoteViews(packageName, R.layout.notification_custom_layout)

        val summerVisible = intent?.getBooleanExtra(EXTRA_SUMMER_VISIBLE, false) ?: false
        val holidayVisible = intent?.getBooleanExtra(EXTRA_HOLIDAY_VISIBLE, false) ?: false
        val customVisible = intent?.getBooleanExtra(EXTRA_CUSTOM_VISIBLE, false) ?: false
        val emptyVisible = intent?.getBooleanExtra(EXTRA_EMPTY_VISIBLE, false) ?: false

        remoteViews.setViewVisibility(R.id.summer_container, if (summerVisible) android.view.View.VISIBLE else android.view.View.GONE)
        remoteViews.setViewVisibility(R.id.holiday_container, if (holidayVisible) android.view.View.VISIBLE else android.view.View.GONE)
        remoteViews.setViewVisibility(R.id.custom_container, if (customVisible) android.view.View.VISIBLE else android.view.View.GONE)
        remoteViews.setViewVisibility(R.id.empty_message, if (emptyVisible) android.view.View.VISIBLE else android.view.View.GONE)

        if (summerVisible) {
            remoteViews.setTextViewText(R.id.summer_label, intent?.getStringExtra(EXTRA_SUMMER_LABEL) ?: "Yaz Tatili")
            remoteViews.setTextViewText(R.id.summer_days, intent?.getStringExtra(EXTRA_SUMMER_DAYS) ?: "")
        }

        if (holidayVisible) {
            remoteViews.setTextViewText(R.id.holiday_label, intent?.getStringExtra(EXTRA_HOLIDAY_LABEL) ?: "Sıradaki Tatil")
            remoteViews.setTextViewText(R.id.holiday_days, intent?.getStringExtra(EXTRA_HOLIDAY_DAYS) ?: "")
        }

        if (customVisible) {
            remoteViews.setTextViewText(R.id.custom_label, intent?.getStringExtra(EXTRA_CUSTOM_LABEL) ?: "Özel Gün")
            remoteViews.setTextViewText(R.id.custom_days, intent?.getStringExtra(EXTRA_CUSTOM_DAYS) ?: "")
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            },
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setCustomContentView(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setShowWhen(false)
            .setContentIntent(pendingIntent)
            .build()
    }
}
