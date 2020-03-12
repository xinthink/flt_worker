package dev.thinkng.flt_worker;

import android.content.Context;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.arch.core.util.Function;

import java.util.List;

import dev.thinkng.flt_worker.internal.AbsWorkerPlugin;
import dev.thinkng.flt_worker.internal.BackgroundWorkerPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** Main entry of the FltWorkerPlugin, dedicated to main isolate. */
@Keep
public class FltWorkerPlugin extends AbsWorkerPlugin {
  /**
   * Provides a callback to register all needed plugins for background workers.
   * 
   * Example:
   * <pre>{@code
   * @Override
   * public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
   *   GeneratedPluginRegistrant.registerWith(flutterEngine);
   *   FltWorkerPlugin.registerPluginsForWorkers = registry -> {
   *     if (!registry.hasPlugin("XPlugin")) {
   *       XPlugin.registerWith(registry.registrarFor("XPlugin"));
   *     }
   *     return null;
   *   };
   * }
   * }</pre>
   * </p>
   */
  public static Function<PluginRegistry, Void> registerPluginsForWorkers;

  @SuppressWarnings("unused")
  public FltWorkerPlugin() {
    super();
  }

  private FltWorkerPlugin(Context context) {
    super(context);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new FltWorkerPlugin(registrar.activity()));
  }

  @Override
  public boolean handleMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    boolean handled = true;
    String method = call.method;
    List args = (List) call.arguments;
    if (method.equals(METHOD_PREFIX + "initialize")) {
      if (args.size() > 1) {
        Long dispatcherHandler = (Long) args.get(0);
        Long workerHandler = (Long) args.get(1);
        getPrefs()
            .edit()
            .putLong("callback_dispatcher_handle", dispatcherHandler)
            .putLong("worker_handle", workerHandler)
            .apply();
      }
      result.success(null);
    } else if (method.equals(METHOD_PREFIX + "test")) {
      try {
        BackgroundWorkerPlugin.getInstance(context).doWork(null);
        result.success(null);
      } catch (Exception e) {
        result.error("E", "worker test failure: " + e.getMessage(), null);
      }
    } else {
      handled = super.handleMethodCall(call, result);
    }
    return handled;
  }
}
