import 'package:flutter/material.dart';

import 'package:flt_worker/flt_worker_ios.dart' as Workers;

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
            onPressed: () async {
              Workers.test(cb);
              bool r = await Workers.submitTaskRequest(Workers.BGAppRefreshTaskRequest("com.example.task1"), taskCallback);
              debugPrint('returns $r');

              r = await Workers.submitTaskRequest(Workers.BGProcessingTaskRequest("com.example.task2",
                earliestBeginDate: DateTime.now(),
                requiresExternalPower: true,
              ), taskCallback);
              debugPrint('returns $r');
            },
          ),
        ),
      ),
    );
}

void cb() {
  debugPrint('--- callback invoked');
  Workers.test(cb1); // register another callback inside the background isolate
}

void cb1() {
  debugPrint('--- callback 01 invoked');
}

void taskCallback() {

}
