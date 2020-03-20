import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// An abstract class representing a work request.
@immutable
abstract class WorkRequest {
  /// Tags for grouping work.
  final Iterable<String> tags;

  /// Input data of the work.
  final Map<String, dynamic> input;

  /// The duration of initial delay of the work.
  final Duration initialDelay;

  /// Initial delay of the work, in microseconds.
  final int initialDelayMicros;

  /// Constraints for the work to run.
  final WorkConstraints constraints;

  /// Sets the backoff policy and backoff delay for the work.
  final BackoffCriteria backoffCriteria;

  /// Extracts initial delay in microseconds from the value of
  /// [initialDelayMicros] or [initialDelay].
  int get _initialDelayMicros =>
    initialDelayMicros != null && initialDelayMicros >= 0
    ? initialDelayMicros
    : max(initialDelay?.inMicroseconds ?? 0, 0);

  /// Instantiates a WorkRequest with optional [tags] and [input] data.
  ///
  /// Optionally provides [initialDelayMicros] or [initialDelay] to specify the initial delay,
  /// if both of them are provided, the value of [initialDelay] will be ignored.
  const WorkRequest({
    this.tags,
    this.input,
    this.initialDelay,
    this.initialDelayMicros,
    this.constraints,
    this.backoffCriteria,
  });

  /// Serializes this work request into a json object.
  Map<String, dynamic> toJson() => {
    'type': (this is OneTimeWorkRequest) ? 'OneTime' : 'Periodic',
    'tags': tags,
    'input': <String, String>{
      'data': jsonEncode(input ?? {}), // always encode the input data
    },
    'initialDelay': _initialDelayMicros,
    'constraints': constraints?.toJson(),
    'backoffCriteria': backoffCriteria?.toJson(),
  };
}

/// Defines an one-off work request.
@immutable
class OneTimeWorkRequest extends WorkRequest {
  /// Instantiates an [OneTimeWorkRequest].
  ///
  /// With optional [tags] and [input] data.
  const OneTimeWorkRequest({
    Iterable<String> tags,
    Map<String, dynamic> input,
    Duration initialDelay,
    int initialDelayMicros,
    WorkConstraints constraints,
    BackoffCriteria backoffCriteria,
  }) : super(
    tags: tags,
    input: input,
    initialDelay: initialDelay,
    initialDelayMicros: initialDelayMicros,
    constraints: constraints,
    backoffCriteria: backoffCriteria,
  );
}

/// Defines a periodic work request.
@immutable
class PeriodWorkRequest extends WorkRequest {
  /// The repeat interval
  final Duration repeatInterval;

  /// The duration for which the work repeats from the end of the [repeatInterval].
  ///
  /// Note that flex intervals are ignored for certain OS versions (in particular, API 23).
  final Duration flexInterval;

  /// Creates a [PeriodWorkRequest] to run periodically once every [repeatInterval] period
  /// , with an optional [flexInterval].
  const PeriodWorkRequest({
    @required this.repeatInterval,
    this.flexInterval,
    Iterable<String> tags,
    Map<String, dynamic> input,
    Duration initialDelay,
    int initialDelayMicros,
    WorkConstraints constraints,
    BackoffCriteria backoffCriteria,
  }) : super(
    tags: tags,
    input: input,
    initialDelay: initialDelay,
    initialDelayMicros: initialDelayMicros,
    constraints: constraints,
    backoffCriteria: backoffCriteria,
  );

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..['repeatInterval'] = repeatInterval.inMicroseconds
    ..['flexInterval'] = flexInterval?.inMicroseconds;
}

/// Constraints for a [WorkRequest].
@immutable
class WorkConstraints {
  /// Whether the work requires a particular [NetworkType] to run.
  ///
  /// The default value is dependent on the native `WorkManager`,
  /// which should be [NetworkType.notRequired] according to
  /// the [documentation](https://developer.android.com/reference/androidx/work/Constraints.Builder?hl=en#setRequiredNetworkType(androidx.work.NetworkType)).
  final NetworkType networkType;

  /// Whether device battery should be at an acceptable level for the work to run.
  ///
  /// The default value is dependent on the native `WorkManager`,
  /// which should be `false` according to
  /// the [documentation](https://developer.android.com/reference/androidx/work/Constraints.Builder?hl=en#setRequiresBatteryNotLow(boolean)).
  final bool batteryNotLow;

  /// Whether device should be charging for the work to run.
  ///
  /// The default value is dependent on the native `WorkManager`,
  /// which should be `false` according to
  /// the [documentation](https://developer.android.com/reference/androidx/work/Constraints.Builder?hl=en#setRequiresCharging(boolean)).
  final bool charging;

  /// Whether device should be idle for the work to run.
  ///
  /// Requires Android SDK level 23+.
  /// The default value is dependent on the native `WorkManager`,
  /// which should be `false` according to
  /// the [documentation](https://developer.android.com/reference/androidx/work/Constraints.Builder?hl=en#setRequiresDeviceIdle(boolean)).
  final bool deviceIdle;

  /// Whether the work requires device's storage should be at an acceptable level.
  ///
  /// The default value is dependent on the native `WorkManager`,
  /// which should be `false` according to
  /// the [documentation](https://developer.android.com/reference/androidx/work/Constraints.Builder?hl=en#setRequiresStorageNotLow(boolean)).
  final bool storageNotLow;

  /// Creates constraints for a [WorkRequest].
  const WorkConstraints({
    this.networkType,
    this.batteryNotLow,
    this.charging,
    this.deviceIdle,
    this.storageNotLow,
  });

  /// Serializes this constraints into a json object.
  Map<String, dynamic> toJson() => {
    'networkType': networkType?.index,
    'batteryNotLow': batteryNotLow,
    'charging': charging,
    'deviceIdle': deviceIdle,
    'storageNotLow': storageNotLow,
  };
}

/// An enumeration of various network types that can be used as [WorkConstraints].
enum NetworkType {
  /// Any working network connection is required for this work.
  connected,

  /// A metered network connection is required for this work.
  metered,

  /// A network is not required for this work.
  notRequired,

  /// A non-roaming network connection is required for this work.
  notRoaming,

  /// An unmetered network connection is required for this work.
  unmetered,
}

/// Sets the backoff policy and backoff delay for the work.
@immutable
class BackoffCriteria {
  /// Backoff policy for the work.
  ///
  /// The default value is dependent on the native `WorkManager`,
  /// which should be [BackoffPolicy.exponential] according to
  /// the [documentation](https://developer.android.com/reference/androidx/work/WorkRequest.Builder#setBackoffCriteria(androidx.work.BackoffPolicy,%20long,%20java.util.concurrent.TimeUnit)).
  final BackoffPolicy policy;

  /// Backoff backoff delay for the work.
  ///
  /// The default value and the valid range is dependent on the native `WorkManager`.
  /// According to the [documentation](https://developer.android.com/reference/androidx/work/WorkRequest.Builder#setBackoffCriteria(androidx.work.BackoffPolicy,%20long,%20java.util.concurrent.TimeUnit))
  /// it defaults to `30` seconds, and will be clamped between `10` seconds and `5` hours.
  final Duration delay;

  /// Creates a [BackoffCriteria] with the backoff [policy] and backoff [delay].
  const BackoffCriteria({
    @required this.policy,
    @required this.delay,
  });

  /// Serializes this backoff criteria into a json object.
  Map<String, dynamic> toJson() => {
    'policy': policy?.index,
    'delay': delay?.inMicroseconds,
  };
}

/// An enumeration of backoff policies when retrying work.
///
/// TODO: These policies are used when you have a return ListenableWorker.Result.retry() from a worker
/// to determine the correct backoff time.
enum BackoffPolicy {
  /// Indicates that the backoff time should be increased exponentially.
  exponential,

  /// Indicates that the backoff time should be increased linearly.
  linear,
}
