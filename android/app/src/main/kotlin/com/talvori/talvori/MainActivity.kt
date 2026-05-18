package com.talvori.talvori

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.talvori.talvori.plugins.AppGroupDirectoryPlugin

class MainActivity : FlutterActivity() {
    private val shareMethodChannel = "talvori/share"
    private val shareEventChannel = "talvori/share/events"
    private var initialSharedText: String? = null
    private var shareEventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(AppGroupDirectoryPlugin())

        initialSharedText = extractSharedText(intent)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shareMethodChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialSharedText" -> {
                        result.success(initialSharedText)
                        initialSharedText = null
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, shareEventChannel)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        shareEventSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        shareEventSink = null
                    }
                }
            )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val sharedText = extractSharedText(intent)
        if (sharedText != null) {
            val sink = shareEventSink
            if (sink != null) {
                sink.success(sharedText)
            } else {
                initialSharedText = sharedText
            }
        }
    }

    private fun extractSharedText(intent: Intent?): String? {
        if (intent == null) return null
        val action = intent.action
        val mimeType = intent.type ?: return null
        val isTextShareAction =
            Intent.ACTION_SEND == action || Intent.ACTION_SEND_MULTIPLE == action
        if (!isTextShareAction || !mimeType.startsWith("text/")) return null

        val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        val trimmed = text?.trim()
        return if (trimmed.isNullOrEmpty()) null else trimmed
    }
}
