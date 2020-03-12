package dev.thinkng.flt_worker;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.arch.core.util.Function;

import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

import dev.thinkng.flt_worker.internal.AbsWorkerPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterRunArguments;

/** Main entry of the FltWorkerPlugin, dedicated to main isolate. */
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

//  private static final String TAG = "FltWorker";
//  private static final String CHANNEL_NAME = "dev.thinkng.flt_worker";
//  private static final String METHOD_PREFIX = "FltWorkerPlugin#";

  // The headless Flutter instance to run the callbacks.
  private static FlutterNativeView headlessView;
  private static final AtomicBoolean headlessViewStarted = new AtomicBoolean();

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  // Channel for callback dispatcher
  private MethodChannel callbackChannel;

//  private static SharedPreferences getPrefs(Context context) {
//    if (prefs == null) {
//      prefs = context.getSharedPreferences(CHANNEL_NAME, Context.MODE_PRIVATE);
//    }
//    return prefs;
//  }

  public FltWorkerPlugin() {
    super();
  }

  public FltWorkerPlugin(Context context) {
    super(context);
  }

//  @Override
//  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
//    super.onAttachedToEngine(flutterPluginBinding);
////    context = flutterPluginBinding.getApplicationContext();
////    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), CHANNEL_NAME);
////    channel.setMethodCallHandler(this);
//  }

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

  private void startHeadlessEngine(Context context) {
    synchronized (headlessViewStarted) {
      if (headlessView == null) {
        long handle = getPrefs().getLong("callback_dispatcher_handle", 0);
        FlutterCallbackInformation cbInfo = FlutterCallbackInformation.lookupCallbackInformation(handle);
        //noinspection ConstantConditions
        if (cbInfo == null) {
          Log.w(TAG, "callback dispatcher handle not found!");
          return;
        }

        headlessView = new FlutterNativeView(context, true);
        // register plugins to the callback isolate
        registerPluginsForHeadlessView();

        FlutterRunArguments args = new FlutterRunArguments();
        args.bundlePath = FlutterMain.findAppBundlePath();
        args.entrypoint = cbInfo.callbackName;
        args.libraryPath = cbInfo.callbackLibraryPath;
        headlessView.runFromBundle(args);
      }

      if (callbackChannel != null) {
        callbackChannel.setMethodCallHandler(null);
      }
      callbackChannel = new MethodChannel(headlessView, CHANNEL_NAME);
      callbackChannel.setMethodCallHandler(this);
    }
  }

  /* Register plugins for the headless isolate */
  private void registerPluginsForHeadlessView() {
    PluginRegistry registry = headlessView.getPluginRegistry();
    if (!registry.hasPlugin("FltWorkerPlugin")) {
      Registrar registrar = registry.registrarFor("FltWorkerPlugin");
//      new MethodChannel(registrar.messenger(), CHANNEL_NAME)
//        .setMethodCallHandler(this);
    }

    if (registerPluginsForWorkers != null) {
      registerPluginsForWorkers.apply(registry);
    }
  }

  /** Dispatch a callback function call */
  private void dispatchCallback(long handle) {
    callbackChannel.invokeMethod(METHOD_PREFIX + "dispatch", Collections.singletonList(handle));
  }

  @Override
  public boolean handleMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String method = call.method;
    List args = (List) call.arguments;
    if (method.equals(METHOD_PREFIX + "initialize")) {
      if (!args.isEmpty()) {
        getPrefs()
            .edit()
            .putLong("callback_dispatcher_handle", ((Long) args.get(0)))
            .apply();
      }
      startHeadlessEngine(context);
      result.success(null);
    } else if (method.equals(METHOD_PREFIX + "test")) {
      if (!args.isEmpty()) {
        dispatchCallback((Long) args.get(0));
      }
      result.success(null);
    } else {
      result.notImplemented();
    }
    return true;
  }
}
