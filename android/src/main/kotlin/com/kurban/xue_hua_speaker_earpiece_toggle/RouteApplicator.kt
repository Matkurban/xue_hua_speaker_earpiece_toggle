package com.kurban.xue_hua_speaker_earpiece_toggle

import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build

internal class RouteApplicator(
    private val audioManager: AudioManager,
    private val detector: RouteDetector,
    private val coordinator: SessionCoordinator
) {
    @Suppress("DEPRECATION")
    fun apply(route: String): RouteApplyResult {
        require(route in AudioRouteNames.SWITCHABLE_ROUTES) {
            "Unknown audio route: $route"
        }

        coordinator.prepareForRouteChange()

        when (route) {
            AudioRouteNames.SPEAKER -> applySpeaker()
            AudioRouteNames.EARPIECE -> applyEarpiece()
        }

        val applied = detector.detect(audioManager)
        return RouteApplyResult(
            applied = applied,
            available = applied == route
        )
    }

    @Suppress("DEPRECATION")
    private fun applySpeaker() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val speaker = audioManager.availableCommunicationDevices.firstOrNull {
                it.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
            }
            if (speaker != null && audioManager.setCommunicationDevice(speaker)) {
                return
            }
        }

        audioManager.isSpeakerphoneOn = true
    }

    @Suppress("DEPRECATION")
    private fun applyEarpiece() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val earpiece = audioManager.availableCommunicationDevices.firstOrNull {
                it.type == AudioDeviceInfo.TYPE_BUILTIN_EARPIECE
            }
            if (earpiece != null && audioManager.setCommunicationDevice(earpiece)) {
                return
            }
        }

        audioManager.isSpeakerphoneOn = false
    }
}
