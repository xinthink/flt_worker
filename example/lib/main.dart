import 'package:flutter/material.dart';

//import 'package:flt_worker/flt_worker.dart';
//import 'package:flt_worker/android.dart';
import 'package:flt_worker/ios.dart';

void main() {
  runApp(MyApp());
  // initializeWorker(doWork); // Android
  initializeWorker(handleBGTask); // iOS
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                  child: const Text('Subimit Tasks'),
                  onPressed: () async {
                    // testWorker();
                    testBGTasks();
                  },
                ),
                RaisedButton(
                  child: const Text('Simulate launch task'),
                  onPressed: () {
                    simulateLaunchTask("com.example.task1");
//                    simulateLaunchTask("dev.example.task2");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
}

/// iOS BGTasks test.
///
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.task1"]
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"dev.example.task2"]
Future<void> testBGTasks() async {
  bool r = await submitTaskRequest(BGAppRefreshTaskRequest("com.example.task1"));
  debugPrint('returns $r');

  r = await submitTaskRequest(BGProcessingTaskRequest("dev.example.task2",
    earliestBeginDate: DateTime.now().add(Duration(seconds: 10)),
    requiresExternalPower: true,
  ));
  debugPrint('returns $r');
}

Future<void> handleBGTask(Map<String, dynamic> payload) async => Future.delayed(Duration(seconds: 1), () async {
  debugPrint('--- doing work in flutter, payload=$payload');
  Map<String, dynamic> input = payload['input'];
  if (input['name'] == 'task 01') {
    debugPrint("    args[2] * opts['op2'] = ${input['args'][2] * input['opts']['op2']}");
  } else if (input['name'] == 'task 02') {
    debugPrint("    args[1] - args[2] = ${input['args'][1] - input['args'][2]}");
  }
});

/// Android WorkManager test.
Future<void> testWorkManager() async {
  // final enqueued = await enqueueWorkRequest(OneTimeWorkRequest(
  //   tags: ['hello', 'work'],
  //   initialDelay: 10000,
  //   input: <String, dynamic>{
  //     'name': 'task 01',
  //     'args': <dynamic>[
  //       'opacity',
  //       0xFF,
  //       0.76,
  //     ],
  //     'opts': <String, dynamic>{
  //       'op': 'minus',
  //       'op1': -1,
  //       'op2': 9.986312,
  //     }
  //   },
  // ));
  // debugPrint('--- enqueued: $enqueued');
}

Future<void> doWork(Map<String, dynamic> payload) async => Future.delayed(Duration(seconds: 1), () async {
  // debugPrint('--- doing work in flutter, payload=$payload');
  // Map<String, dynamic> input = payload['input'];
  // if (input['name'] == 'task 01') {
  //   debugPrint("    args[2] * opts['op2'] = ${input['args'][2] * input['opts']['op2']}");
  //   final enqueued = await enqueueWorkRequest(OneTimeWorkRequest(
  //     tags: ['task'],
  //     initialDelay: 2000,
  //     input: <String, dynamic>{
  //       'name': 'task 02',
  //       'args': <dynamic>[ 'opacity', 0xFF, 0.76 ],
  //     },
  //   ));
  //   debugPrint('    task#02 enqueued: $enqueued');
  // } else if (input['name'] == 'task 02') {
  //   debugPrint("    args[1] - args[2] = ${input['args'][1] - input['args'][2]}");
  // }
});
