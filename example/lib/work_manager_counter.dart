import 'package:flt_worker/android.dart';
import 'package:flutter/material.dart';

import 'counter_file.dart';

/// WorkManager api example for the Android platform.
class WorkManagerCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Counter (WorkManager)'),
    ),
    body: SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: _buildCounter(),
      ),
    ),
  );

  /// Renders the latest counter by watching a data file.
  Widget _buildCounter() => StreamBuilder<int>(
    stream: counterStream(),
    builder: (_, snapshot) => Column(
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Increases the counter via an one-off work\n',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            children: <TextSpan>[
              TextSpan(
                text: snapshot.hasData ? '${snapshot.data}' : '',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 48,
                  height: 1.618,
                ),
              ),
            ],
          ),
        ),
        RaisedButton(
          child: const Text('Count'),
          onPressed: () => _increaseCounter(snapshot.data),
        ),
      ],
    )
  );

  /// Enqueues a work request to update the counter.
  void _increaseCounter(int counter) {
    enqueueWorkRequest(OneTimeWorkRequest(
      tags: [kTagCounterWork],
      constraints: WorkConstraints(
        networkType: NetworkType.notRequired,
      ),
      input: <String, dynamic>{
        'counter': counter,
      },
    ));
  }
}
