package com.kurban.xue_hua_speaker_earpiece_toggle

import android.media.AudioManager

internal class SessionCoordinator(
    private val audioManager: AudioManager
) {
    private var savedMode: Int? = null
    private var modeChanged = false

    fun prepareForRouteChange() {
        if (savedMode == null) {
            savedMode = audioManager.mode
        }

        if (audioManager.mode != AudioManager.MODE_IN_COMMUNICATION) {
            audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
            modeChanged = true
        }
    }

    fun restoreIfNeeded() {
        val previousMode = savedMode ?: return

        if (modeChanged) {
            audioManager.mode = previousMode
        }

        savedMode = null
        modeChanged = false
    }
}
