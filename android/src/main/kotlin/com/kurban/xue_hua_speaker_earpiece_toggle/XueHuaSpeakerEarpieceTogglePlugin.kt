package com.kurban.xue_hua_speaker_earpiece_toggle

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** XueHuaSpeakerEarpieceTogglePlugin */
class XueHuaSpeakerEarpieceTogglePlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "xue_hua_speaker_earpiece_toggle")
        channel.setMethodCallHandler(this)
        applicationContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getRoute" -> {
                try {
                    result.success(getCurrentRoute())
                } catch (exception: Exception) {
                    result.error(
                        "AUDIO_ROUTE_ERROR",
                        exception.message,
                        null
                    )
                }
            }
            "setRoute" -> {
                val route = call.argument<String>("route")
                if (route == null) {
                    result.error(
                        "INVALID_ARGUMENT",
                        "Missing route argument.",
                        null
                    )
                    return
                }

                try {
                    setRoute(route)
                    result.success(null)
                } catch (exception: IllegalArgumentException) {
                    result.error(
                        "INVALID_ROUTE",
                        exception.message,
                        null
                    )
                } catch (exception: Exception) {
                    result.error(
                        "AUDIO_ROUTE_ERROR",
                        exception.message,
                        null
                    )
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun audioManager(): AudioManager {
        return applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    private fun getCurrentRoute(): String {
        return if (audioManager().isSpeakerphoneOn) ROUTE_SPEAKER else ROUTE_EARPIECE
    }

    private fun setRoute(route: String) {
        val audioManager = audioManager()
        when (route) {
            ROUTE_SPEAKER -> {
                audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
                audioManager.isSpeakerphoneOn = true
            }
            ROUTE_EARPIECE -> {
                audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
                audioManager.isSpeakerphoneOn = false
            }
            else -> throw IllegalArgumentException("Unknown audio route: $route")
        }
    }

    companion object {
        private const val ROUTE_SPEAKER = "speaker"
        private const val ROUTE_EARPIECE = "earpiece"
    }
}
