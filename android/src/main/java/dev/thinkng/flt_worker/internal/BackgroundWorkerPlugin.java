package dev.thinkng.flt_worker.internal;

import android.content.Context;
import android.util.Log;

import java.util.Collections;
import java.util.concurrent.atomic.AtomicBoolean;

import dev.thinkng.flt_worker.FltWorkerPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterRunArguments;

/** WorkerPlugin dedicated to the background isolate. */
public class BackgroundWorkerPlugin extends AbsWorkerPlugin {
  private static BackgroundWorkerPlugin instance;

  BackgroundWorkerPlugin getInstance(Context context) {
    synchronized (BackgroundWorkerPlugin.class) {
      if (instance == null) {
        instance = new BackgroundWorkerPlugin(context);
      }
    }
    return instance;
  }

  // The headless Flutter instance to run the callbacks.
  private FlutterNativeView headlessView;
  private final AtomicBoolean headlessViewStarted = new AtomicBoolean();

  private BackgroundWorkerPlugin(Context context) {
    super(context);
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

      if (channel != null) {
        channel.setMethodCallHandler(null);
      }
      channel = new MethodChannel(headlessView, CHANNEL_NAME);
      channel.setMethodCallHandler(this);
    }
  }

  /* Register plugins for the headless isolate */
  private void registerPluginsForHeadlessView() {
    PluginRegistry registry = headlessView.getPluginRegistry();
//    if (!registry.hasPlugin("FltWorkerPlugin")) {
//      PluginRegistry.Registrar registrar = registry.registrarFor("FltWorkerPlugin");
//      new MethodChannel(registrar.messenger(), CHANNEL_NAME)
//        .setMethodCallHandler(this);
//    }

    if (FltWorkerPlugin.registerPluginsForWorkers != null) {
      FltWorkerPlugin.registerPluginsForWorkers.apply(registry);
    }
  }

  /** Dispatch a callback function call */
  private void dispatchCallback(long handle) {
    channel.invokeMethod(METHOD_PREFIX + "dispatch", Collections.singletonList(handle));
  }
}
