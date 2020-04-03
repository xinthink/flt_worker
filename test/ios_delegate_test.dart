import 'dart:math';

import 'package:flt_worker/flt_worker.dart';
import 'package:flt_worker/ios.dart';
import 'package:flt_worker/src/background_tasks/delegate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tranform unified model to BackgroundTasks terms', () {
    var intent = WorkIntent(
      identifier: 'work1',
    );
    var req = parseWorkIntent(intent);
    expect(req, isA<BGAppRefreshTaskRequest>());
    expect(req.identifier, 'work1');
    expect(req.earliestBeginDate, null);
    expect(req.input, null);

    intent = WorkIntent(
      identifier: 'work2',
      isProcessingTask: true,
    );
    req = parseWorkIntent(intent);
    expect(req, isA<BGProcessingTaskRequest>());
    expect(req.identifier, 'work2');
    expect((req as BGProcessingTaskRequest).requiresNetworkConnectivity, isNull);
    expect((req as BGProcessingTaskRequest).requiresExternalPower, isNull);
  });

  test('parse BGProcessingTaskRequest with constraints', () {
    final now = DateTime.now();
    var intent = WorkIntent(
      identifier: 'work1',
      initialDelay: Duration(minutes: 11),
      isProcessingTask: true,
      constraints: WorkConstraints(
        networkType: NetworkType.notRoaming,
        charging: true,
      ),
    );
    var req = parseWorkIntent(intent) as BGProcessingTaskRequest;
    expect(
        (req.earliestBeginDate.millisecondsSinceEpoch - now.add(Duration(minutes: 11)).millisecondsSinceEpoch).abs(),
        lessThanOrEqualTo(1000));
    expect(req.requiresNetworkConnectivity, isTrue);
    expect(req.requiresExternalPower, isTrue);

    intent = WorkIntent(
      identifier: 'work1',
      isProcessingTask: true,
      constraints: WorkConstraints(
        networkType: NetworkType.notRequired,
        charging: false,
      ),
    );
    req = parseWorkIntent(intent) as BGProcessingTaskRequest;
    expect(req.requiresNetworkConnectivity, isFalse);
    expect(req.requiresExternalPower, isFalse);
  });
}
