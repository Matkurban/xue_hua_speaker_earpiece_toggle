package com.kurban.xue_hua_speaker_earpiece_toggle

import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build

internal class RouteDetector {
    @Suppress("DEPRECATION")
    fun detect(audioManager: AudioManager): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val device = audioManager.communicationDevice
            if (device != null) {
                return mapCommunicationDevice(device.type)
            }
        }

        if (audioManager.isBluetoothScoOn || audioManager.isWiredHeadsetOn) {
            return AudioRouteNames.EXTERNAL
        }

        return if (audioManager.isSpeakerphoneOn) {
            AudioRouteNames.SPEAKER
        } else {
            AudioRouteNames.EARPIECE
        }
    }

    private fun mapCommunicationDevice(type: Int): String {
        return when (type) {
            AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> AudioRouteNames.SPEAKER
            AudioDeviceInfo.TYPE_BUILTIN_EARPIECE -> AudioRouteNames.EARPIECE
            AudioDeviceInfo.TYPE_WIRED_HEADSET,
            AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
            AudioDeviceInfo.TYPE_BLUETOOTH_SCO,
            AudioDeviceInfo.TYPE_BLUETOOTH_A2DP,
            AudioDeviceInfo.TYPE_BLE_HEADSET,
            AudioDeviceInfo.TYPE_USB_HEADSET,
            AudioDeviceInfo.TYPE_USB_DEVICE -> AudioRouteNames.EXTERNAL

            else -> AudioRouteNames.UNKNOWN
        }
    }
}
