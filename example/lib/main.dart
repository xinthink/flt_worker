import 'package:flutter/material.dart';

// import 'package:flt_worker/flt_worker_ios.dart' as Workers;
import 'package:flt_worker/flt_worker.dart' as Workers;

void main() {
  runApp(MyApp());
  Workers.initialize();
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
            onPressed: () {
              Workers.test(testPlugins);
            },
          ),
        ),
      ),
    );
}

/// plugins should also work in the background isolate
void testPlugins() {
  debugPrint('--- callback invoked'); // background isolate is up
  Workers.test(cb1); // register another callback inside the background isolate
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
