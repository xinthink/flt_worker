import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flt_worker/flt_worker.dart';
//import 'package:flt_worker/android.dart';
//import 'package:flt_worker/ios.dart';

import 'background_tasks_btc_prices.dart';
import 'background_tasks_counter.dart';
import 'work_manager_btc_prices.dart';
import 'work_manager_counter.dart';
import 'worker.dart';

void main() {
  runApp(MyApp());
//  initializeWorker(doWork); // Android
//  initializeWorker(handleBGTask); // iOS
  initializeWorker(worker);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Worker Examples'),
      ),
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
            child: DefaultTextStyle(
              textAlign: TextAlign.center,
              style: const TextStyle(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  RaisedButton(
                    child: const Text('Counter \n(high level API)'),
                    onPressed: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 16),
                    child: const Text('Low level platform-specific API examples',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  ...(Platform.isAndroid ? _workManagerExamples(context) : _bgTasksExamples(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

List<Widget> _workManagerExamples(BuildContext context) => [
  RaisedButton(
    child: const Text('Counter \n(OneTimeWorkRequest)'),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => WorkManagerCounter(),
      ));
    },
  ),
  RaisedButton(
    child: const Text('Bitcoin price polling \n(PeriodicWorkRequest)'),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => WorkManagerBtcPrices(),
      ));
    },
  ),
];

List<Widget> _bgTasksExamples(BuildContext context) => [
  RaisedButton(
    child: const Text('Counter \n(BGProcessingTaskRequest)'),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => BackgroundTasksCounter(),
      ));
    },
  ),
  RaisedButton(
    child: const Text('Bitcoin price polling \n(BGAppRefreshTaskRequest)'),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => BackgroundTasksBtcPrices(),
      ));
    },
  ),
];

/// iOS BGTasks test.
///
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.btc_prices_task"]
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.counter_task"]
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.task1"]
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"dev.example.task2"]
Future<void> testBGTasks() async {
//  bool r = await submitTaskRequest(BGAppRefreshTaskRequest("com.example.task1"));
//  debugPrint('returns $r');
//
//  r = await submitTaskRequest(BGProcessingTaskRequest("dev.example.task2",
//    earliestBeginDate: DateTime.now().add(Duration(seconds: 10)),
//    requiresExternalPower: true,
//  ));
//  debugPrint('returns $r');
}

//Future<void> handleBGTask(Map<String, dynamic> payload) async => Future.delayed(Duration(seconds: 1), () async {
//  debugPrint('--- doing work in flutter, payload=$payload');
//  Map<String, dynamic> input = payload['input'];
//  if (input['name'] == 'task 01') {
//    debugPrint("    args[2] * opts['op2'] = ${input['args'][2] * input['opts']['op2']}");
//  } else if (input['name'] == 'task 02') {
//    debugPrint("    args[1] - args[2] = ${input['args'][1] - input['args'][2]}");
//  }
//});
//
///// Android WorkManager test.
//Future<void> testWorkManager() async {
//   final enqueued = await enqueueWorkRequest(const OneTimeWorkRequest(
//     tags: ['hello', 'work'],
//     initialDelay: Duration(seconds: 10),
//     constraints: WorkConstraints(
//       networkType: NetworkType.notRoaming,
//     ),
//     backoffCriteria: BackoffCriteria(
//       policy: BackoffPolicy.linear,
//       delay: Duration(seconds: 20),
//     ),
//     input: <String, dynamic>{
//       'name': 'task 01',
//       'args': <dynamic>[
//         'opacity',
//         0xFF,
//         0.76,
//       ],
//       'opts': <String, dynamic>{
//         'op': 'minus',
//         'op1': -1,
//         'op2': 9.986312,
//       }
//     },
//   ));
//   debugPrint('--- enqueued: $enqueued');
//}
//
//Future<void> doWork(WorkPayload payload) async => Future.delayed(Duration(seconds: 1), () async {
//   debugPrint('--- doing work in flutter, payload=$payload');
//   Map<String, dynamic> input = payload.input;
//   if (input['name'] == 'task 01') {
//     debugPrint("    args[2] * opts['op2'] = ${input['args'][2] * input['opts']['op2']}");
//     final enqueued = await enqueueWorkRequest(const OneTimeWorkRequest(
//       tags: ['task'],
//       initialDelay: Duration(seconds: 2),
//       input: <String, dynamic>{
//         'name': 'task 02',
//         'args': <dynamic>['opacity', 0xFF, 0.76],
//       },
//     ));
//     debugPrint('    task#02 enqueued: $enqueued');
//   } else if (input['name'] == 'task 02') {
//     debugPrint("    args[1] - args[2] = ${input['args'][1] - input['args'][2]}");
//   }
//});
