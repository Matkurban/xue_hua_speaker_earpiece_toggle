package com.kurban.xue_hua_speaker_earpiece_toggle

internal object AudioRouteNames {
    const val SPEAKER = "speaker"
    const val EARPIECE = "earpiece"
    const val EXTERNAL = "external"
    const val UNKNOWN = "unknown"

    val SWITCHABLE_ROUTES = setOf(SPEAKER, EARPIECE)
}

internal data class RouteApplyResult(
    val applied: String,
    val available: Boolean
) {
    fun toMap(): Map<String, Any> = mapOf(
        "applied" to applied,
        "available" to available
    )
}
