package dev.thinkng.flt_worker.internal;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.annotation.UiThread;
import androidx.work.Operation;
import androidx.work.WorkManager;
import androidx.work.WorkRequest;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.FutureTask;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

@Keep
public abstract class AbsWorkerPlugin implements FlutterPlugin, MethodCallHandler {
  static final String TAG = "FltWorker";
  protected static final String CHANNEL_NAME = "dev.thinkng.flt_worker";
  protected static final String METHOD_PREFIX = "FltWorkerPlugin#";

  protected Context context;
  private SharedPreferences prefs;
  private final ExecutorService workMgrExecutor = Executors.newCachedThreadPool();
  private Handler mainHandler;

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  MethodChannel channel;

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
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
    }
    workMgrExecutor.shutdownNow();
  }

  @UiThread
  @Override
  final public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if(!handleMethodCall(call, result)) {
      result.notImplemented();
    }
  }

  @SuppressWarnings({"unused", "BooleanMethodIsAlwaysInverted"})
  public boolean handleMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    boolean handled = true;
    switch (call.method) {
      case METHOD_PREFIX + "enqueue":
        enqueue(call, result);
        break;
      case METHOD_PREFIX + "cancelAllWorkByTag":
        cancelAllWorkByTag(call, result);
        break;
      case METHOD_PREFIX + "cancelUniqueWork":
        cancelUniqueWork(call, result);
        break;
      case METHOD_PREFIX + "cancelWorkById":
        cancelWorkById(call, result);
        break;
      case METHOD_PREFIX + "cancelAllWork":
        cancelAllWork(call, result);
        break;
      default:
        handled = false;
        break;
    }
    return handled;
  }

  private void enqueue(@NonNull MethodCall call, @NonNull final Result result) {
    List<? extends WorkRequest> requests = WorkRequests.parseRequests(call.arguments);
    if (requests == null || requests.isEmpty()) {
      result.success(false);
      return;
    }

    Operation op = WorkManager.getInstance(context).enqueue(requests);
    watchOperation(op, result, "enqueueWorkRequests");
  }

  private void cancelAllWorkByTag(@NonNull MethodCall call, @NonNull final Result result) {
    Operation op = WorkManager.getInstance(context).cancelAllWorkByTag((String) call.arguments);
    watchOperation(op, result, "cancelAllWorkByTag");
  }

  private void cancelUniqueWork(@NonNull MethodCall call, @NonNull final Result result) {
    Operation op = WorkManager.getInstance(context).cancelUniqueWork((String) call.arguments);
    watchOperation(op, result, "cancelUniqueWork");
  }

  private void cancelWorkById(@NonNull MethodCall call, @NonNull final Result result) {
    Operation op = WorkManager.getInstance(context).cancelWorkById(UUID.fromString((String) call.arguments));
    watchOperation(op, result, "cancelWorkById");
  }

  private void cancelAllWork(@NonNull MethodCall call, @NonNull final Result result) {
    Operation op = WorkManager.getInstance(context).cancelAllWork();
    watchOperation(op, result, "cancelAllWork");
  }

  /**
   * Waits for the operation's completion, and reports the result.
   */
  private void watchOperation(@NonNull final Operation operation,
                              @NonNull final Result result,
                              final String operationDesc) {
    workMgrExecutor.execute(new Runnable() {
      @Override
      public void run() {
        Throwable err = null;
        try {
          operation.getResult().get();
        } catch (Throwable e) {
          err = e;
        }
        reportResult(result, err, operationDesc);
      }
    });
  }

  private void reportResult(@NonNull final Result result,
                            final Throwable e,
                            final String operationDesc) {
    // reporting results on UI thread
    runOnMainThread(new Runnable() {
      @Override
      public void run() {
        if (e != null) {
          result.error("E", "Failed to " + operationDesc + ": " + e.getMessage(), null);
        } else {
          result.success(true);
        }
      }
    });
  }

  private void ensureMainHandler() {
    synchronized (AbsWorkerPlugin.class) {
      if (mainHandler == null) {
        mainHandler = new Handler(Looper.getMainLooper());
      }
    }
  }

//  /** Run the given [callable] on the main thread. */
//  <T> Future<T> runOnMainThread(final Callable<T> callable) {
//    ensureMainHandler();
//    FutureTask<T> task = new FutureTask<>(callable);
//    mainHandler.post(task);
//    return task;
//  }

  /** Run the given [runnable] on the main thread. */
  Future<Void> runOnMainThread(final Runnable runnable) {
    ensureMainHandler();
    FutureTask<Void> task = new FutureTask<>(runnable, null);
    mainHandler.post(task);
    return task;
  }
}
