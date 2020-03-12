package dev.thinkng.flt_worker.internal;

import android.content.Context;
import android.util.Log;

import androidx.annotation.Keep;
import androidx.annotation.Nullable;
import androidx.annotation.UiThread;
import androidx.work.Worker;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;

import dev.thinkng.flt_worker.FltWorkerPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterRunArguments;

/** WorkerPlugin dedicated to the background isolate. */
@Keep
public class BackgroundWorkerPlugin extends AbsWorkerPlugin {
  private static BackgroundWorkerPlugin instance;

  public static BackgroundWorkerPlugin getInstance(Context context) {
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

  /**
   * Callback for doing the background work.
   */
  public Future<Void> doWork(@Nullable Worker worker) throws ExecutionException, InterruptedException {
    if (worker != null) {
      Log.d(TAG, "executing Work id=" + worker.getId() + " tags=" + worker.getTags());
    } else {
      Log.d(TAG, "executing an empty Work (test only)");
    }

    runOnMainThread(new Runnable() {
      @Override
      public void run() {
        startHeadlessEngine(context);
      }
    }).get();
    return dispatchCallback(getPrefs().getLong("worker_handle", 0), worker);
  }

  @UiThread
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
  private Future<Void> dispatchCallback(final long handle,
                                        @Nullable final Worker worker)
      throws InterruptedException, ExecutionException {
    final Map<String, Object> payload = new HashMap<>();
    if (worker != null) {
      // worker is null only if it's a testing request
      payload.put("id", worker.getId().toString());
      payload.put("input", worker.getInputData().getKeyValueMap());

      LinkedList<String> tags = new LinkedList<>();
      for (String tag : worker.getTags()) {
        if (!tag.startsWith("dev.thinkng.flt_worker")) {
          tags.add(tag);
        }
      }
      payload.put("tags", tags);
    }

    final MethodCallFuture<Void> callback = new MethodCallFuture<>();
    runOnMainThread(new Runnable() {
      @Override
      public void run() {
        channel.invokeMethod(METHOD_PREFIX + "dispatch",
            Arrays.asList(handle, payload),
            callback);
      }
    }).get();
    return callback;
  }
}
