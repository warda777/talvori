package eu.talvori.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import eu.talvori.app.plugins.AppGroupDirectoryPlugin
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val shareMethodChannel = "talvori/share"
    private val shareEventChannel = "talvori/share/events"
    private var initialSharedPayload: Map<String, Any?>? = null
    private var shareEventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(AppGroupDirectoryPlugin())

        initialSharedPayload = extractSharedPayload(intent)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shareMethodChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialSharedText" -> {
                        result.success(initialSharedPayload)
                        initialSharedPayload = null
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
        val sharedPayload = extractSharedPayload(intent)
        if (sharedPayload != null) {
            val sink = shareEventSink
            if (sink != null) {
                sink.success(sharedPayload)
            } else {
                initialSharedPayload = sharedPayload
            }
        }
    }

    private fun extractSharedPayload(intent: Intent?): Map<String, Any?>? {
        if (intent == null) return null
        val action = intent.action
        val mimeType = intent.type ?: return null
        val isTextShareAction =
            Intent.ACTION_SEND == action || Intent.ACTION_SEND_MULTIPLE == action
        if (!isTextShareAction || !mimeType.startsWith("text/")) return null

        val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        val trimmed = text?.trim()
        if (trimmed.isNullOrEmpty()) return null
        val sourceUrl = extractWebUrl(trimmed)
        return mapOf(
            "id" to UUID.randomUUID().toString(),
            "text" to trimmed,
            "createdAt" to (System.currentTimeMillis() / 1000.0),
            "source" to "android_share_intent",
            "type" to if (sourceUrl == trimmed) "url" else "text",
            "sourceUrl" to sourceUrl,
            "sharedTextPreview" to trimmed.take(120),
            "browserHint" to "android_share_sheet",
            "platform" to "android",
        )
    }

    private fun extractWebUrl(text: String): String? {
        val match = Regex("(https?://[^\\s<>()\\[\\]]+|www\\.[^\\s<>()\\[\\]]+)")
            .find(text)
            ?.value
            ?: return null
        return if (match.startsWith("www.")) "https://$match" else match
    }
}
