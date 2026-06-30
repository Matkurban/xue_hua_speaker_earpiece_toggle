package com.kurban.xue_hua_speaker_earpiece_toggle

import android.content.Context
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

internal class RouteChangeNotifier(
    context: Context,
    private val controller: AudioRouteController
) : EventChannel.StreamHandler {
    private val audioManager =
        context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null
    private var deviceCallback: AudioDeviceCallback? = null
    private var communicationDeviceListener: AudioManager.OnCommunicationDeviceChangedListener? =
        null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        controller.onRouteChanged = { route ->
            mainHandler.post { eventSink?.success(route) }
        }
        registerListeners()
        events?.success(controller.getRoute())
    }

    override fun onCancel(arguments: Any?) {
        unregisterListeners()
        controller.onRouteChanged = null
        eventSink = null
    }

    private fun registerListeners() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val listener = AudioManager.OnCommunicationDeviceChangedListener {
                emitCurrentRoute()
            }
            communicationDeviceListener = listener
            audioManager.addOnCommunicationDeviceChangedListener(
                mainHandler::post,
                listener
            )
        }

        val callback =
            object : AudioDeviceCallback() {
                override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>) {
                    emitCurrentRoute()
                }

                override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo>) {
                    emitCurrentRoute()
                }
            }
        deviceCallback = callback
        audioManager.registerAudioDeviceCallback(callback, mainHandler)
    }

    private fun unregisterListeners() {
        deviceCallback?.let { audioManager.unregisterAudioDeviceCallback(it) }
        deviceCallback = null

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            communicationDeviceListener?.let {
                audioManager.removeOnCommunicationDeviceChangedListener(it)
            }
        }
        communicationDeviceListener = null
    }

    private fun emitCurrentRoute() {
        mainHandler.post { eventSink?.success(controller.getRoute()) }
    }
}
