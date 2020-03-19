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
  });

  /// Serializes this work request into a json object.
  Map<String, dynamic> toJson() => {
    'type': (this is OneTimeWorkRequest) ? 'OneTime' : 'Periodic',
    'tags': tags,
    'input': <String, String>{
      'data': jsonEncode(input ?? ''), // always encode the input data
    },
    'initialDelay': _initialDelayMicros,
  };
}

@immutable
class OneTimeWorkRequest extends WorkRequest {
  /// Instantiates a WorkRequest with optional [tags] and [input] data.
  const OneTimeWorkRequest({
    Iterable<String> tags,
    Map<String, dynamic> input,
    Duration initialDelay,
    int initialDelayMicros,
  }) : super(tags: tags, input: input, initialDelay: initialDelay, initialDelayMicros: initialDelayMicros);
}

@immutable
class PeriodWorkRequest extends WorkRequest {

}
