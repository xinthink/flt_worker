import 'dart:convert';

import 'package:flutter/foundation.dart';

/// An abstract class for representing task requests.
@immutable
abstract class BGTaskRequest {
  /// The identifier of the task associated with the request.
  final String identifier;

  /// The earliest date and time at which to run the task.
  ///
  /// Specify `null` for no start delay.
  ///
  /// Setting the property indicates that the background task shouldn’t start any earlier than this date.
  /// However, the system doesn't guarantee launching the task at the specified date, but only that it won’t begin sooner.
  final DateTime? earliestBeginDate;

  /// Input data of the task.
  final Map<String, dynamic>? input;

  /// Initializes a [BGTaskRequest] instance with the given [identifier].
  ///
  /// Optional properties:
  /// - [earliestBeginDate]
  /// - [input]
  const BGTaskRequest(this.identifier, {
    this.earliestBeginDate,
    this.input,
  });

  Map<String, dynamic> toJson() => {
    'type': (this is BGAppRefreshTaskRequest) ? 'AppRefresh' : 'Processing',
    'identifier': identifier,
    'earliestBeginDate': earliestBeginDate?.millisecondsSinceEpoch,
    'input': jsonEncode(input ?? {}),
  };
}

/// A request to launch your app in the background to execute a short refresh task.
@immutable
class BGAppRefreshTaskRequest extends BGTaskRequest {
  /// Instantiates a [BGAppRefreshTaskRequest] with the task [identifier]
  /// and an optional [earliestBeginDate].
  const BGAppRefreshTaskRequest(String identifier, {
    DateTime? earliestBeginDate,
    Map<String, dynamic>? input,
  }) : super(identifier, earliestBeginDate: earliestBeginDate, input: input);
}

/// A request to launch your app in the background to execute a processing task that can take minutes to complete.
@immutable
class BGProcessingTaskRequest extends BGTaskRequest {
  /// Specifies if the processing task requires a device connected to power.
  final bool? requiresExternalPower;

  /// Specifies if the processing task requires network connectivity.
  final bool? requiresNetworkConnectivity;

  /// Instantiates a [BGProcessingTaskRequest] with the task [identifier].
  ///
  /// and an optional [earliestBeginDate].
  const BGProcessingTaskRequest(String identifier, {
    DateTime? earliestBeginDate,
    Map<String, dynamic>? input,
    this.requiresExternalPower,
    this.requiresNetworkConnectivity,
  }) : super(identifier, earliestBeginDate: earliestBeginDate, input: input);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['requiresExternalPower'] = requiresExternalPower;
    json['requiresNetworkConnectivity'] = requiresNetworkConnectivity;
    return json;
  }
}
