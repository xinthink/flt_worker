package dev.thinkng.flt_worker.internal;

import androidx.annotation.Nullable;
import androidx.annotation.UiThread;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import io.flutter.plugin.common.MethodChannel;

@SuppressWarnings("unchecked")
public class MethodCallFuture<T> implements MethodChannel.Result, Future<T> {
  private final byte[] lock = new byte[0];
  private volatile boolean isComplete;
  private volatile Object result;
  private volatile Exception error;

  @UiThread
  @Override
  public void success(Object o) {
    synchronized (lock) {
      result = o;
      isComplete = true;
      lock.notifyAll();
    }
  }

  @UiThread
  @Override
  public void error(String errorCode, String errorMessage, Object errorDetails) {
    synchronized (lock) {
      error = new RuntimeException(error + " " + errorMessage + (errorDetails != null ? " " + errorDetails : ""));
      isComplete = true;
      lock.notifyAll();
    }
  }

  @UiThread
  @Override
  public void notImplemented() {
    synchronized (lock) {
      isComplete = true;
      lock.notifyAll();
    }
  }

  @Override
  public boolean cancel(boolean b) {
    return false;
  }

  @Override
  public boolean isCancelled() {
    return false;
  }

  @Override
  public boolean isDone() {
    return isComplete;
  }

  @Nullable
  @Override
  public T get() throws ExecutionException, InterruptedException {
    synchronized (lock) {
      while (!isComplete) {
        lock.wait();
      }

      if (error != null) {
        throw new ExecutionException("", error);
      }
      return (T) result;
    }
  }

  @Nullable
  @Override
  public T get(long timeout, TimeUnit timeUnit) throws ExecutionException, InterruptedException, TimeoutException {
    synchronized (lock) {
      long timeoutMillis = timeUnit.toMillis(timeout);
      long t = System.currentTimeMillis();
      while (!isComplete) {
        lock.wait(timeoutMillis);
        if (System.currentTimeMillis() - t >= timeoutMillis) {
          throw new TimeoutException("timed out waiting for the result to complete");
        }
      }

      if (error != null) {
        throw new ExecutionException("", error);
      }
      return (T) result;
    }
  }
}
