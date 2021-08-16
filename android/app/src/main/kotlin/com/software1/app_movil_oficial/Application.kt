package com.software1.app_movil_oficial

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService

// Nota, esta linea la agregue
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin

class Application : FlutterApplication(), PluginRegistrantCallback {
    override
    fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingService.setPluginRegistrant(this)
    }

    override
    fun registerWith(registry: PluginRegistry) {
        // GeneratedPluginRegistrant.registerWith(registry);
        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
    }
}