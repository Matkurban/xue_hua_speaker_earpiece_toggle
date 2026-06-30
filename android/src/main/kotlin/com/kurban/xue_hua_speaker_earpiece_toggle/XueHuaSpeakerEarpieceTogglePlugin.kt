package com.kurban.xue_hua_speaker_earpiece_toggle

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** XueHuaSpeakerEarpieceTogglePlugin */
class XueHuaSpeakerEarpieceTogglePlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var controller: AudioRouteController
    private lateinit var routeChangeNotifier: RouteChangeNotifier

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "xue_hua_speaker_earpiece_toggle"
        )
        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "xue_hua_speaker_earpiece_toggle/events"
        )
        channel.setMethodCallHandler(this)
        controller = AudioRouteController(flutterPluginBinding.applicationContext)
        routeChangeNotifier = RouteChangeNotifier(
            flutterPluginBinding.applicationContext,
            controller
        )
        eventChannel.setStreamHandler(routeChangeNotifier)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getRoute" -> result.success(controller.getRoute())
            "setRoute" -> handleSetRoute(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel.setStreamHandler(null)
        controller.restoreSessionIfNeeded()
        channel.setMethodCallHandler(null)
    }

    private fun handleSetRoute(call: MethodCall, result: Result) {
        val route = when (val rawRoute = call.argument<Any?>("route")) {
            is String -> rawRoute
            null -> {
                result.error(
                    "INVALID_ARGUMENT",
                    "Missing route argument.",
                    null
                )
                return
            }
            else -> {
                result.error(
                    "INVALID_ARGUMENT",
                    "Route argument must be a string.",
                    null
                )
                return
            }
        }

        if (route !in AudioRouteNames.SWITCHABLE_ROUTES) {
            result.error(
                "INVALID_ROUTE",
                "Unknown audio route: $route",
                null
            )
            return
        }

        try {
            result.success(controller.setRoute(route).toMap())
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
}
