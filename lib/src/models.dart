import 'dart:convert';

import 'package:flutter/foundation.dart';

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
