import 'package:flutter/material.dart';

// import 'package:flt_worker/flt_worker_ios.dart' as Workers;
import 'package:flt_worker/flt_worker_android.dart';
// import 'package:flt_worker/flt_worker.dart' as Workers;

void main() {
  runApp(MyApp());
  initializeWorker(doWork);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: RaisedButton(
            child: const Text('Test Callback'),
            onPressed: () async {
              // testWorker();
              final enqueued = await enqueueWorkRequest(OneTimeWorkRequest(
                tags: ['hello', 'work'],
                initialDelay: 10000,
                input: <String, dynamic>{
                  'name': 'task 01',
                  'args': <dynamic>[
                    'opacity',
                    0xFF,
                    0.76,
                  ],
                  'opts': <String, dynamic>{
                    'op': 'minus',
                    'op1': -1,
                    'op2': 9.986312,
                  }
                },
              ));
              debugPrint('--- enqueued: $enqueued');
            },
          ),
        ),
      ),
    );
}

/// plugins should also work in the background isolate
void testPlugins() {
  debugPrint('--- callback invoked'); // background isolate is up
  // testWorker(); // register another callback inside the background isolate
}

void cb1() {
  debugPrint('--- callback 01 invoked');
}

void taskCallback() {
  debugPrint('--- background task started...');
}

/// iOS BGTasks test.
///
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.task1"]
/// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"dev.example.task2"]
Future<void> testBGTasks() async {
//   bool r = await Workers.submitTaskRequest(Workers.BGAppRefreshTaskRequest("com.example.task1"), taskCallback);
//   debugPrint('returns $r');

//   r = await Workers.submitTaskRequest(Workers.BGProcessingTaskRequest("dev.example.task2",
//     earliestBeginDate: DateTime.now(),
//     requiresExternalPower: true,
//   ), taskCallback);
//   debugPrint('returns $r');
}

Future<void> doWork(Map<String, dynamic> payload) async => Future.delayed(Duration(seconds: 1), () async {
  debugPrint('--- doing work in flutter, payload=$payload');
  Map<String, dynamic> input = payload['input'];
  if (input['name'] == 'task 01') {
    debugPrint("    args[2] * opts['op2'] = ${input['args'][2] * input['opts']['op2']}");
    final enqueued = await enqueueWorkRequest(OneTimeWorkRequest(
      tags: ['task'],
      initialDelay: 2000,
      input: <String, dynamic>{
        'name': 'task 02',
        'args': <dynamic>[ 'opacity', 0xFF, 0.76 ],
      },
    ));
    debugPrint('    task#02 enqueued: $enqueued');
  } else if (input['name'] == 'task 02') {
    debugPrint("    args[1] - args[2] = ${input['args'][1] - input['args'][2]}");
  }
});
