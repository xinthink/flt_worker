package dev.thinkng.flt_worker.internal;

import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.core.util.Pair;
import androidx.work.BackoffPolicy;
import androidx.work.Constraints;
import androidx.work.Data;
import androidx.work.NetworkType;
import androidx.work.OneTimeWorkRequest;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkRequest;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

final class WorkRequests {
  private WorkRequests() {}

  @Nullable
  static List<? extends WorkRequest> parseRequests(@NonNull Object input) {
    if (!(input instanceof List) || ((List) input).isEmpty()) {
      return null;
    }

    List<WorkRequest> requests = new ArrayList<>();
    List requestsJson = (List) input;
    for (Object json : requestsJson) {
      if (json instanceof Map) {
        requests.add(parseRequest((Map) json));
      }
    }
    return requests;
  }

  @SuppressWarnings("WeakerAccess")
  @VisibleForTesting
  @NonNull
  public static WorkRequest parseRequest(@NonNull Map json) {
    try {
      String type = (String) json.get("type");
      if ("Periodic".equals(type)) {
        return new PeriodicWorkRequest.Builder(BackgroundWorker.class, 0, TimeUnit.SECONDS)
            .build();
      } else {
        return parseOneTimeWorkRequest(json);
      }
    } catch (Exception e) {
      throw new IllegalArgumentException("Failed to parse WorkRequest from " + json, e);
    }
  }

  @NonNull
  private static WorkRequest parseOneTimeWorkRequest(@NonNull Map json) {
    OneTimeWorkRequest.Builder builder = new OneTimeWorkRequest.Builder(BackgroundWorker.class);

    Object tagsJson = json.get("tags");
    if (tagsJson instanceof Iterable) {
      for (Object tag : (List) tagsJson) {
        builder.addTag((String) tag);
      }
    }

    Object delayJson = json.get("initialDelay");
    if (delayJson instanceof Number) {
      long delay = ((Number) delayJson).longValue();
      if (delay > 0) {
        builder.setInitialDelay(delay, TimeUnit.MICROSECONDS);
      }
    }

    Constraints constraints = parseConstraints(json.get("constraints"));
    if (constraints != null) {
      builder.setConstraints(constraints);
    }

    Pair<BackoffPolicy, Long> backoffCriteria = parseBackoffCriteria(json.get("backoffCriteria"));
    if (backoffCriteria != null) {
      //noinspection ConstantConditions
      builder.setBackoffCriteria(backoffCriteria.first,
          backoffCriteria.second, TimeUnit.MICROSECONDS);
    }

    Object inputJson = json.get("input");
    if (inputJson instanceof Map) {
      //noinspection unchecked
      builder.setInputData(new Data.Builder()
          .putAll((Map<String, Object>) inputJson)
          .build());
    }
    return builder.build();
  }

  @Nullable
  private static Pair<BackoffPolicy, Long> parseBackoffCriteria(@Nullable Object json) {
    if (json instanceof Map) {
      Map criteria = (Map) json;
      Integer policy = (Integer) criteria.get("policy");
      if (policy != null) {
        Number delay = (Number) criteria.get("delay");
        if (delay != null) {
          return new Pair<>(
              policy == 1 ? BackoffPolicy.LINEAR : BackoffPolicy.EXPONENTIAL,
              delay.longValue()
          );
        }
      }
    }

    return null;
  }

  @SuppressWarnings("ConstantConditions")
  @Nullable
  private static Constraints parseConstraints(@Nullable Object json) {
    if (!(json instanceof Map)) {
      return null;
    }

    Map constraintsJson = (Map) json;
    Constraints.Builder builder = new Constraints.Builder();

    if (constraintsJson.get("networkType") != null) {
      builder.setRequiredNetworkType(
          NetworkType.values()[(Integer) constraintsJson.get("networkType")]);
    }
    if (constraintsJson.get("batteryNotLow") != null) {
      builder.setRequiresBatteryNotLow((Boolean) constraintsJson.get("batteryNotLow"));
    }
    if (constraintsJson.get("charging") != null) {
      builder.setRequiresCharging((Boolean) constraintsJson.get("charging"));
    }
    if (Build.VERSION.SDK_INT >= 23 && constraintsJson.get("deviceIdle") != null) {
      builder.setRequiresDeviceIdle((Boolean) constraintsJson.get("deviceIdle"));
    }
    if (constraintsJson.get("storageNotLow") != null) {
      builder.setRequiresStorageNotLow((Boolean) constraintsJson.get("storageNotLow"));
    }

    return builder.build();
  }
}
