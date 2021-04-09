import 'package:flt_worker/android.dart';
import 'package:flt_worker/flt_worker.dart';
import 'package:flt_worker/src/work_manager/delegate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tranform unified model to WorkManager terms', () {
    var intent = WorkIntent(
      identifier: 'work1',
    );
    var req = parseWorkIntent(intent);
    expect(req, isA<OneTimeWorkRequest>());
    expect(req.tags, ['work1']);
    expect(req.initialDelay, null);
    expect(req.input, null);
    expect(req.constraints, null);
    expect(req.backoffCriteria, null);

    intent = WorkIntent(
      identifier: 'work2',
      tags: ['periodic'],
      repeatInterval: Duration(hours: 4),
    );
    req = parseWorkIntent(intent);
    expect(req, isA<PeriodicWorkRequest>());
    expect(req.tags, ['work2', 'periodic']);
    expect((req as PeriodicWorkRequest).repeatInterval, Duration(hours: 4));

    intent = WorkIntent(
      identifier: 'work2',
      tags: ['periodic'],
      repeatInterval: Duration(hours: 4),
      flexInterval: Duration(minutes: 1),
    );
    req = parseWorkIntent(intent);
    expect(req, isA<PeriodicWorkRequest>());
    expect(req.tags, ['work2', 'periodic']);
    expect((req as PeriodicWorkRequest).repeatInterval, Duration(hours: 4));
    expect(req.flexInterval, Duration(minutes: 1));
  });

  test('model tranformation with constraints', () {
    // default constraints (empty)
    var intent = WorkIntent(
      identifier: 'work1',
      initialDelay: Duration(seconds: 59),
      constraints: WorkConstraints(),
    );
    var req = parseWorkIntent(intent);
    var constraints = req.constraints!;
    expect(req.initialDelay, Duration(seconds: 59));
    expect(constraints, isNotNull);
    expect(constraints.batteryNotLow, isNull);
    expect(constraints.charging, isNull);
    expect(constraints.deviceIdle, isNull);
    expect(constraints.networkType, isNull);
    expect(constraints.storageNotLow, isNull);

    intent = WorkIntent(
      identifier: 'work1',
      constraints: WorkConstraints(
        batteryNotLow: true,
        charging: false,
        deviceIdle: true,
        networkType: NetworkType.metered,
        storageNotLow: false,
      ),
    );
    req = parseWorkIntent(intent);
    constraints = req.constraints!;
    expect(constraints.batteryNotLow, isTrue);
    expect(constraints.charging, isFalse);
    expect(constraints.deviceIdle, isTrue);
    expect(constraints.networkType, NetworkType.metered);
    expect(constraints.storageNotLow, isFalse);
  });
}
