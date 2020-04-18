# flt_worker_example

Demonstrates how to use the flt_worker plugin.

## Examples

High-level API examples:
- [counter.dart]: Counter demo the worker way
- [btc_prices.dart]: refreshing Bitcoin price periodically in the background
- [worker.dart]: the worker dispather example

Android low-level API examples:
- [work_manager_counter.dart]: Counter using an `OneTimeWorkRequest`
- [work_manager_btc_prices.dart]: refreshing Bitcoin price periodically using a `PeriodicWorkRequest`

iOS low-level API examples:
- [background_tasks_counter.dart]: Counter using a `BGProcessingTaskRequest`
- [background_tasks_btc_prices.dart]: refreshing Bitcoin price periodically using `BGAppRefreshTaskRequest`s

## Debugging on iOS

For debugging your worker on an iOS device, you may want to force launch a `BGTaskRequest`.

Please follow these steps:
1. Run your app using Xcode
2. Set a breakpoint at the last line of the `handleMethodCall` method in `flt_worker/ios/Classes/FltWorkerPlugin.m`
3. When the app pauses (after submission of a `BGTaskRequest`), execute the following line in the debugger, substituting your task identifier for `TASK_IDENTIFIER`, and resume the app.

```
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"TASK_IDENTIFIER"]
```

Please find more details here: [Starting and Terminating Tasks During Development].


[worker.dart]: https://github.com/xinthink/flt_worker/blob/master/example/lib/worker.dart
[counter.dart]: https://github.com/xinthink/flt_worker/blob/master/example/lib/counter.dart
[btc_prices.dart]: https://github.com/xinthink/flt_worker/blob/master/example/lib/btc_prices.dart
[background_tasks_btc_prices.dart]: https://github.com/xinthink/flt_worker/blob/master/example/lib/background_tasks_btc_prices.dart
[background_tasks_counter.dart]: https://github.com/xinthink/flt_worker/blob/master/example/lib/background_tasks_counter.dart
[work_manager_btc_prices.dart]: https://github.com/xinthink/flt_worker/blob/master/example/lib/work_manager_btc_prices.dart
[work_manager_counter.dart]: https://github.com/xinthink/flt_worker/blob/master/example/lib/work_manager_counter.dart
[Starting and Terminating Tasks During Development]: https://developer.apple.com/documentation/backgroundtasks/starting_and_terminating_tasks_during_development
