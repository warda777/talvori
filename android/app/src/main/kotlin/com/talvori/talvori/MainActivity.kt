package com.talvori.talvori

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.talvori.talvori.plugins.AppGroupDirectoryPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(AppGroupDirectoryPlugin())
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Wichtig: Neuen Intent an Flutter Engine weiterreichen
        // Das share_handler Plugin kann dann darauf reagieren
        setIntent(intent)
    }
}
