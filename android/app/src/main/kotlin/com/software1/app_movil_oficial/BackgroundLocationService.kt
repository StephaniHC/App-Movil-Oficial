package com.software1.app_movil_oficial

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.annotation.Nullable


class BackgroundLocationService : Service() {

    internal val PRIORITY_HIGH = 1
   @Nullable
    override
    fun onBind(intent: Intent): IBinder {
        return Binder()
    }


    override
    fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0)

        val builder = Notification.Builder(this)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationChannel = NotificationChannel("app.meedu/background-location",
                    "Meedu.app Background Location",
                    NotificationManager.IMPORTANCE_DEFAULT)

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(notificationChannel)


            builder.setChannelId("app.meedu/background-location")
        }

        builder.setContentTitle("MEEDU.APP")
                .setContentText("Escuchando cambios en la ubicación")
                // .setSmallIcon(R.drawable.ic_launcher)
                .setContentIntent(pendingIntent)

        val notification = builder.build()

        startForeground(PRIORITY_HIGH, notification)

        return START_NOT_STICKY
    }
}
