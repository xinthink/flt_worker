package dev.thinkng.flt_worker.internal;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.work.Data;
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

  @NonNull
  private static WorkRequest parseRequest(@NonNull Map json) {
    try {
      String type = (String) json.get("type");
      if ("OneTime".equals(type)) {
        return parseOneTimeWorkRequest(json);
      } else {
        return new PeriodicWorkRequest.Builder(BackgroundWorker.class, 0, TimeUnit.SECONDS)
            .build();
      }
    } catch (Exception e) {
      throw new IllegalArgumentException("Failed to parse WorkRequest from " + json, e);
    }
  }

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
        builder.setInitialDelay(delay, TimeUnit.MILLISECONDS);
      }
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
}
