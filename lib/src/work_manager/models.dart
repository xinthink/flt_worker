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

  /// Initial delay of the work, in milliseconds.
  final int initialDelay;

  /// Instantiates a WorkRequest with optional [tags] and [input] data.
  const WorkRequest({
    this.tags,
    this.input,
    this.initialDelay,
  });

  /// Serializes this work request into a json object.
  Map<String, dynamic> toJson() => {
    'type': (this is OneTimeWorkRequest) ? 'OneTime' : 'Periodic',
    'tags': tags,
    'input': <String, String>{
      'data': jsonEncode(input ?? ''), // always encode the input data
    },
    'initialDelay': max(initialDelay ?? 0, 0),
  };
}

@immutable
class OneTimeWorkRequest extends WorkRequest {
  /// Instantiates a WorkRequest with optional [tags] and [input] data.
  const OneTimeWorkRequest({
    Iterable<String> tags,
    Map<String, dynamic> input,
    int initialDelay,
  }) : super(tags: tags, input: input, initialDelay: initialDelay);
}
