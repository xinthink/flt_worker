import 'dart:async';
import 'dart:io';

import 'background_tasks/delegate.dart' as bg;
import 'models.dart';
import 'work_manager/delegate.dart' as wm;

/// Enqueues a request to work in the background.
final Future<bool> Function(WorkIntent intent) enqueueWorkIntent =
  Platform.isAndroid ? wm.enqueueWorkIntent : bg.enqueueWorkIntent;

/// Cancels all unfinished work with the given [identifier].
///
/// Note that cancellation is a best-effort policy and work that is already executing may continue to run.
final Future<bool> Function(String id) cancelWork =
  Platform.isAndroid ? wm.cancelWork : bg.cancelWork;

/// Cancels all unfinished work.
///
/// **Use this method with extreme caution!**
/// By invoking it, you will potentially affect other modules or libraries in your codebase.
/// It is strongly recommended that you use one of the other cancellation methods at your disposal.
final Future<bool> Function() cancelAllWork =
  Platform.isAndroid ? wm.wmCancelAllWork : bg.cancelAllWork;
