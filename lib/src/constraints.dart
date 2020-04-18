import 'package:flutter/foundation.dart';

/// Constraints for a [WorkIntent].
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
