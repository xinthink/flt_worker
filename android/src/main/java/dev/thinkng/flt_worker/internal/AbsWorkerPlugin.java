package dev.thinkng.flt_worker.internal;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public abstract class AbsWorkerPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
  protected static final String TAG = "FltWorker";
  protected static final String CHANNEL_NAME = "dev.thinkng.flt_worker";
  protected static final String METHOD_PREFIX = "FltWorkerPlugin#";

  protected Context context;
  private SharedPreferences prefs;

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  protected MethodChannel channel;

  public AbsWorkerPlugin() {
  }

  public AbsWorkerPlugin(Context context) {
    this.context = context.getApplicationContext();
  }

  protected SharedPreferences getPrefs() {
    if (prefs == null) {
      prefs = context.getSharedPreferences(CHANNEL_NAME, Context.MODE_PRIVATE);
    }
    return prefs;
  }

  @SuppressWarnings("deprecation")
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    if (context == null) {
      context = flutterPluginBinding.getApplicationContext();
    }
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @Override
  final public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    handleMethodCall(call, result);
  }

  @SuppressWarnings("unused")
  public boolean handleMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    return false;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
    }
  }
}
