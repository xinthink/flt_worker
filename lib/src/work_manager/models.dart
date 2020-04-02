import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../types.dart';

export '../types.dart';

/// An abstract class representing a work request.
@immutable
abstract class WorkRequest {
  /// Tags for grouping work.
  final Iterable<String> tags;

  /// Input data of the work.
  final Map<String, dynamic> input;

  /// The duration of initial delay of the work.
  final Duration initialDelay;

  /// Constraints for the work to run.
  final WorkConstraints constraints;

  /// Sets the backoff policy and backoff delay for the work.
  final BackoffCriteria backoffCriteria;

  /// Instantiates a WorkRequest with optional [tags] and [input] data.
  ///
  /// Optionally provides an [initialDelay].
  const WorkRequest({
    this.tags,
    this.input,
    this.initialDelay,
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
    'initialDelay': max(initialDelay?.inMicroseconds ?? 0, 0),
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
    WorkConstraints constraints,
    BackoffCriteria backoffCriteria,
  }) : super(
    tags: tags,
    input: input,
    initialDelay: initialDelay,
    constraints: constraints,
    backoffCriteria: backoffCriteria,
  );
}

/// Defines a periodic work request.
@immutable
class PeriodicWorkRequest extends WorkRequest {
  /// The repeat interval
  final Duration repeatInterval;

  /// The duration for which the work repeats from the end of the [repeatInterval].
  ///
  /// Note that flex intervals are ignored for certain OS versions (in particular, API 23).
  final Duration flexInterval;

  /// Creates a [PeriodicWorkRequest] to run periodically once every [repeatInterval] period
  /// , with an optional [flexInterval].
  const PeriodicWorkRequest({
    @required this.repeatInterval,
    this.flexInterval,
    Iterable<String> tags,
    Map<String, dynamic> input,
    Duration initialDelay,
    WorkConstraints constraints,
    BackoffCriteria backoffCriteria,
  }) : super(
    tags: tags,
    input: input,
    initialDelay: initialDelay,
    constraints: constraints,
    backoffCriteria: backoffCriteria,
  );

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..['repeatInterval'] = repeatInterval.inMicroseconds
    ..['flexInterval'] = flexInterval?.inMicroseconds;
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
