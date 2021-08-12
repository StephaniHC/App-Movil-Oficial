package com.software1.app_movil_oficial


import android.content.Intent
import android.os.Build

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull


class MainActivity : FlutterActivity() {


    override
    fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.getDartExecutor().getBinaryMessenger()
        val channel = MethodChannel(messenger, "app.meedu/background-location")

        channel.setMethodCallHandler({ call, result ->
            when (call.method) {
                "start" -> start()

                "stop" -> stop()

                else -> result.notImplemented()
            }
        })
    }


    internal fun start() {

        val intent = Intent(this, BackgroundLocationService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }

    }


    internal fun stop() {
        val intent = Intent(this, BackgroundLocationService::class.java)
        stopService(intent)
    }

    override
    protected fun onDestroy() {
        stop()
        super.onDestroy()
    }
}
