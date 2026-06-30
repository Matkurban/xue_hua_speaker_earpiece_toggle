package com.kurban.xue_hua_speaker_earpiece_toggle

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.ArgumentMatchers.eq
import org.mockito.Mockito
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`

internal class XueHuaSpeakerEarpieceTogglePluginTest {
    private lateinit var plugin: XueHuaSpeakerEarpieceTogglePlugin
    private lateinit var mockResult: MethodChannel.Result
    private lateinit var mockContext: Context
    private lateinit var mockAudioManager: AudioManager

    @BeforeEach
    fun setUp() {
        plugin = XueHuaSpeakerEarpieceTogglePlugin()
        mockResult = mock(MethodChannel.Result::class.java)
        mockContext = mock(Context::class.java)
        mockAudioManager = mock(AudioManager::class.java)

        `when`(mockContext.getSystemService(Context.AUDIO_SERVICE)).thenReturn(mockAudioManager)

        val binding = mock(FlutterPlugin.FlutterPluginBinding::class.java)
        `when`(binding.applicationContext).thenReturn(mockContext)
        `when`(binding.binaryMessenger).thenReturn(mock())

        plugin.onAttachedToEngine(binding)
    }

    @AfterEach
    fun tearDown() {
        Mockito.reset(mockResult, mockContext, mockAudioManager)
    }

    @Test
    fun onMethodCall_getRoute_returnsSpeakerWhenSpeakerphoneOn() {
        `when`(mockAudioManager.isSpeakerphoneOn).thenReturn(true)
        `when`(mockAudioManager.isBluetoothScoOn).thenReturn(false)
        `when`(mockAudioManager.isWiredHeadsetOn).thenReturn(false)

        plugin.onMethodCall(MethodCall("getRoute", null), mockResult)

        verify(mockResult).success("speaker")
    }

    @Test
    fun onMethodCall_getRoute_returnsExternalWhenHeadsetConnected() {
        `when`(mockAudioManager.isSpeakerphoneOn).thenReturn(false)
        `when`(mockAudioManager.isBluetoothScoOn).thenReturn(false)
        `when`(mockAudioManager.isWiredHeadsetOn).thenReturn(true)

        plugin.onMethodCall(MethodCall("getRoute", null), mockResult)

        verify(mockResult).success("external")
    }

    @Test
    fun onMethodCall_getRoute_returnsEarpieceWhenSpeakerphoneOff() {
        `when`(mockAudioManager.isSpeakerphoneOn).thenReturn(false)
        `when`(mockAudioManager.isBluetoothScoOn).thenReturn(false)
        `when`(mockAudioManager.isWiredHeadsetOn).thenReturn(false)

        plugin.onMethodCall(MethodCall("getRoute", null), mockResult)

        verify(mockResult).success("earpiece")
    }

    @Test
    fun onMethodCall_setRoute_speaker_returnsRouteResult() {
        `when`(mockAudioManager.isSpeakerphoneOn).thenReturn(true)
        `when`(mockAudioManager.isBluetoothScoOn).thenReturn(false)
        `when`(mockAudioManager.isWiredHeadsetOn).thenReturn(false)

        plugin.onMethodCall(
            MethodCall("setRoute", mapOf("route" to "speaker")),
            mockResult
        )

        verify(mockAudioManager).mode = AudioManager.MODE_IN_COMMUNICATION
        verify(mockAudioManager).isSpeakerphoneOn = true
        verify(mockResult).success(
            mapOf(
                "applied" to "speaker",
                "available" to true
            )
        )
    }

    @Test
    fun onMethodCall_setRoute_earpiece_returnsRouteResult() {
        `when`(mockAudioManager.isSpeakerphoneOn).thenReturn(false)
        `when`(mockAudioManager.isBluetoothScoOn).thenReturn(false)
        `when`(mockAudioManager.isWiredHeadsetOn).thenReturn(false)

        plugin.onMethodCall(
            MethodCall("setRoute", mapOf("route" to "earpiece")),
            mockResult
        )

        verify(mockAudioManager).mode = AudioManager.MODE_IN_COMMUNICATION
        verify(mockAudioManager).isSpeakerphoneOn = false
        verify(mockResult).success(
            mapOf(
                "applied" to "earpiece",
                "available" to true
            )
        )
    }

    @Test
    fun onMethodCall_setRoute_unknownRoute_returnsInvalidRouteError() {
        plugin.onMethodCall(
            MethodCall("setRoute", mapOf("route" to "unknown")),
            mockResult
        )

        verify(mockResult).error(
            eq("INVALID_ROUTE"),
            eq("Unknown audio route: unknown"),
            eq(null)
        )
    }

    @Test
    fun onMethodCall_setRoute_missingRoute_returnsInvalidArgumentError() {
        plugin.onMethodCall(MethodCall("setRoute", null), mockResult)

        verify(mockResult).error(
            eq("INVALID_ARGUMENT"),
            eq("Missing route argument."),
            eq(null)
        )
    }

    @Test
    fun onMethodCall_setRoute_wrongTypeRoute_returnsInvalidArgumentError() {
        plugin.onMethodCall(
            MethodCall("setRoute", mapOf("route" to 1)),
            mockResult
        )

        verify(mockResult).error(
            eq("INVALID_ARGUMENT"),
            eq("Route argument must be a string."),
            eq(null)
        )
    }

    @Test
    fun onMethodCall_unknownMethod_returnsNotImplemented() {
        plugin.onMethodCall(MethodCall("unknownMethod", null), mockResult)

        verify(mockResult).notImplemented()
    }

    @Test
    fun onDetachedFromEngine_restoresSavedMode() {
        `when`(mockAudioManager.mode).thenReturn(AudioManager.MODE_NORMAL)

        plugin.onMethodCall(
            MethodCall("setRoute", mapOf("route" to "speaker")),
            mockResult
        )

        val binding = mock(FlutterPlugin.FlutterPluginBinding::class.java)
        plugin.onDetachedFromEngine(binding)

        verify(mockAudioManager).mode = AudioManager.MODE_NORMAL
    }
}
