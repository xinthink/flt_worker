import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'constraints.dart';

export 'constraints.dart';

/// Describes a work request.
///
/// The name `WorkIntent` is chosen to avoid conflict with the term `WorkRequest` on the Android platform.
@immutable
class WorkIntent {
  /// The identifier of the work.
  ///
  /// Will be added to [tags] implicitly, which can be retrieved from [WorkPayload].
  /// TODO platform-specific info
  final String identifier;

  /// Tags for grouping work.
  ///
  /// Tags except [identifier] are only available on **Android**.
  final Iterable<String> tags;

  /// Input data of the work.
  final Map<String, dynamic> input;

  /// The duration of initial delay of the work.
  final Duration initialDelay;

  /// Constraints for the work to run.
  final WorkConstraints constraints;

  /// **iOS** only, requests to schedule a `BGProcessingTaskRequest`,
  /// which defaults to `BGAppRefreshTaskRequest` if not specified.
  final bool isProcessingTask;

  /// **Android** only. The repeat interval of a periodic work request.
  final Duration repeatInterval;

  /// **Android** only. The duration for which the work repeats from the end of the [repeatInterval].
  ///
  /// Note that flex intervals are ignored for certain Android OS versions (in particular, API 23).
  final Duration flexInterval;

  /// Instantiates a [WorkIntent] with an [identifier].
  ///
  /// Optional properties include [tags], [input] data and an [initialDelay].
  const WorkIntent({
    @required this.identifier,
    this.tags,
    this.input,
    this.initialDelay,
    this.constraints,
    this.isProcessingTask,
    this.repeatInterval,
    this.flexInterval,
  });
}

/// Payload of a background work.
@immutable
class WorkPayload {
  /// Id of the work.
  ///
  /// It's the BGTask identifier on iOS, and work UUID on Android.
  final String id;

  /// Tags of the work.
  ///
  /// Tags except [identifier] are only available on **Android**.
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
