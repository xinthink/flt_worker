package dev.thinkng.flt_worker.internal;

import android.content.Context;
import android.util.Log;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.work.Worker;
import androidx.work.WorkerParameters;

@Keep
public class BackgroundWorker extends Worker {

  public BackgroundWorker(@NonNull Context context, @NonNull WorkerParameters params) {
    super(context, params);
  }

  @NonNull
  @Override
  public Result doWork() {
    try {
      BackgroundWorkerPlugin.getInstance(getApplicationContext())
          .doWork(this)
          .get();
      return Result.success();
    } catch (Throwable e) {
      Log.e(AbsWorkerPlugin.TAG, "worker execution failure", e);
      return Result.failure();
    }
  }
}
