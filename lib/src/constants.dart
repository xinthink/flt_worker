import 'package:flutter/services.dart';

const CHANNEL_NAME = 'dev.thinkng.flt_worker';
const METHOD_PREFIX = 'FltWorkerPlugin';

/// The shared method channel for api calls
const apiChannel = const MethodChannel(CHANNEL_NAME);
