import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'types.dart';

export 'types.dart';

/// Describes a work request.
///
/// The name `WorkIntent` is chosen to avoid conflict with the term `WorkRequest` on the Android platform.
@immutable
class WorkIntent {
  /// The id of the work.
  ///
  /// TODO platform-specific info
  final String id;

  /// Tags for grouping work.
  final Iterable<String> tags;

  /// Input data of the work.
  final Map<String, dynamic> input;

  /// The duration of initial delay of the work.
  final Duration initialDelay;

  /// Constraints for the work to run.
  final WorkConstraints constraints;

  /// iOS only, requests to schedule a `BGProcessingTaskRequest`,
  /// which defaults to `BGAppRefreshTaskRequest` if not specified.
  final bool isProcessingTask;

  /// Instantiates a [WorkIntent] with an [id].
  ///
  /// Optional properties include [tags], [input] data and an [initialDelay].
  const WorkIntent({
    @required this.id,
    this.tags,
    this.input,
    this.initialDelay,
    this.constraints,
    this.isProcessingTask,
  });
}

/// Payload of a background work.
@immutable
class WorkPayload {
  /// Identifier of the work.
  final String id;

  /// Tags of the work, available on Android only.
  final Iterable<String> tags;

  /// Input of the work.
  final Map<String, dynamic> input;

  /// Instantiates the payload for a work.
  const WorkPayload._({this.id, this.tags, this.input});

  /// Decodes the input json into a [WorkPayload].
  factory WorkPayload.fromJson(Map<String, dynamic> json) {
    Map input = json['input'] ?? {};
    String inputJson = input['data'];
    input = inputJson?.isNotEmpty == true ? jsonDecode(inputJson) : {};
    return WorkPayload._(
      id: json['id'],
      tags: Iterable.castFrom<dynamic, String>(json['tags'] ?? []),
      input: input,
    );
  }
}
