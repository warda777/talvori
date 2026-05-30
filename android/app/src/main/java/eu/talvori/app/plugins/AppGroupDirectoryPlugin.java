package eu.talvori.app.plugins;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class AppGroupDirectoryPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  private Context context;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "app_group_directory");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getAppGroupDirectory")) {
      // Für Android gibt es kein App Group Directory Konzept
      // Wir geben den App-spezifischen Verzeichnispfad zurück
      result.success(context.getFilesDir().getAbsolutePath());
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
