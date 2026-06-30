package com.kurban.xue_hua_speaker_earpiece_toggle

import android.content.Context
import android.media.AudioManager

internal class AudioRouteController(
    context: Context
) {
    private val audioManager =
        context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val detector = RouteDetector()
    private val coordinator = SessionCoordinator(audioManager)
    private val applicator = RouteApplicator(audioManager, detector, coordinator)

    var onRouteChanged: ((String) -> Unit)? = null

    fun getRoute(): String = detector.detect(audioManager)

    fun setRoute(route: String): RouteApplyResult {
        val result = applicator.apply(route)
        onRouteChanged?.invoke(detector.detect(audioManager))
        return result
    }

    fun restoreSessionIfNeeded() {
        coordinator.restoreIfNeeded()
    }
}
