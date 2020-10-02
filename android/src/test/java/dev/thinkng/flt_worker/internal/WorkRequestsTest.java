package dev.thinkng.flt_worker.internal;

import android.os.Build;

import androidx.work.BackoffPolicy;
import androidx.work.Constraints;
import androidx.work.NetworkType;
import androidx.work.OneTimeWorkRequest;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkRequest;

import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.*;

public class WorkRequestsTest {

  @Test
  public void parseOneTimeWorkRequest() {
    Map<String, Object> json = new HashMap<>();
    json.put("tags", Arrays.asList("test", "work"));
    json.put("initialDelay", 10000000); // 10 seconds in microseconds

    WorkRequest req = WorkRequests.parseRequest(json);

    assertTrue(req instanceof OneTimeWorkRequest);
    assertEquals(Arrays.asList(BackgroundWorker.class.getName(), "test", "work"),
        new ArrayList<>(req.getTags()));
    assertEquals(10000, req.getWorkSpec().initialDelay); // 10 seconds in milliseconds
  }

  @Test
  public void parsePeriodicWorkRequest() {
    Map<String, Object> json = new HashMap<>();
    json.put("type", "Periodic");
    json.put("repeatInterval", 86400 * 1000000L); // 1 day in microseconds
    json.put("tags", Arrays.asList("test", "periodic"));
    json.put("initialDelay", 10000000); // 10 seconds in microseconds

    WorkRequest req = WorkRequests.parseRequest(json);

    assertTrue(req instanceof PeriodicWorkRequest);
    assertEquals(Arrays.asList(BackgroundWorker.class.getName(), "test", "periodic"),
        new ArrayList<>(req.getTags()));
    assertEquals(10000, req.getWorkSpec().initialDelay); // 10 seconds in milliseconds
    assertEquals(86400 * 1000L, req.getWorkSpec().intervalDuration); // 1 day in milliseconds
  }

  @Test
  public void parseBackoffCriteria() {
    Map<String, Object> json = new HashMap<>();
    Map<String, Object> backoffCriteriaJson = new HashMap<>();
    backoffCriteriaJson.put("policy", BackoffPolicy.LINEAR.ordinal());
    backoffCriteriaJson.put("delay", 12000000); // 12 seconds in microseconds
    json.put("backoffCriteria", backoffCriteriaJson);

    WorkRequest req = WorkRequests.parseRequest(json);

    assertEquals(BackoffPolicy.LINEAR, req.getWorkSpec().backoffPolicy);
    assertEquals(12000, req.getWorkSpec().backoffDelayDuration); // 12 seconds in milliseconds
  }

  @Test
  public void parseInvalidBackoffCriteria() {
    // empty criteria
    Map<String, Object> json = new HashMap<>();
    Map<String, Object> backoffCriteriaJson = new HashMap<>();
    json.put("backoffCriteria", backoffCriteriaJson);

    WorkRequest req = WorkRequests.parseRequest(json);

    // should fallback to defaults
    assertEquals(BackoffPolicy.EXPONENTIAL, req.getWorkSpec().backoffPolicy);

    // the same should happen to an incomplete criteria
    backoffCriteriaJson.put("policy", BackoffPolicy.LINEAR.ordinal());
    req = WorkRequests.parseRequest(json);
    assertEquals(BackoffPolicy.EXPONENTIAL, req.getWorkSpec().backoffPolicy);

    json.clear();
    backoffCriteriaJson.put("delay", 12000000);
    req = WorkRequests.parseRequest(json);
    assertEquals(BackoffPolicy.EXPONENTIAL, req.getWorkSpec().backoffPolicy);
    assertEquals(WorkRequest.DEFAULT_BACKOFF_DELAY_MILLIS, req.getWorkSpec().backoffDelayDuration);
  }

  @SuppressWarnings("ConstantConditions")
  @Test
  public void parseConstraints() {
    Map<String, Object> constraintsJson = new HashMap<>();
    constraintsJson.put("networkType", NetworkType.NOT_ROAMING.toString());
    constraintsJson.put("batteryNotLow", true);
    constraintsJson.put("charging", null);
    constraintsJson.put("deviceIdle", true);
    constraintsJson.put("storageNotLow", false);

    Map<String, Object> reqJson = new HashMap<>();
    reqJson.put("constraints", constraintsJson);
    WorkRequest req = WorkRequests.parseRequest(reqJson);

    assertTrue("should has constraints", req.getWorkSpec().hasConstraints());
    final Constraints constraints = req.getWorkSpec().constraints;
    assertEquals(NetworkType.NOT_ROAMING, constraints.getRequiredNetworkType());
    assertTrue(constraints.requiresBatteryNotLow());
    if (Build.VERSION.SDK_INT >= 23) assertTrue(constraints.requiresDeviceIdle());
    assertFalse(constraints.requiresStorageNotLow());
    assertFalse(constraints.requiresCharging()); // fallback to defaults
  }

  @Test
  public void parseFlexInterval() {
    Map<String, Object> json = new HashMap<>();
    json.put("type", "Periodic");
    json.put("repeatInterval", 86400 * 1000000L); // 1 day in microseconds
    json.put("flexInterval", 600 * 1000000L); // 10 minutes in microseconds

    WorkRequest req = WorkRequests.parseRequest(json);

    assertTrue(req instanceof PeriodicWorkRequest);
    assertEquals(86400 * 1000L, req.getWorkSpec().intervalDuration); // 1 day in milliseconds
    assertEquals(600 * 1000L, req.getWorkSpec().flexDuration); // 10 minutes in milliseconds
  }
}
