#import "FltWorkerPlugin.h"
#import <BackgroundTasks/BackgroundTasks.h>

#define PLUGIN_PKG "dev.thinkng.flt_worker"
#define API_METHOD(NAME) "FltWorkerPlugin#"#NAME

@implementation FltWorkerPlugin {
  FlutterEngine *_headlessEngine;
  FlutterMethodChannel *_callbackChannel;
  BOOL _isHeadlessEnginRegistered;
}

static FltWorkerPlugin *instance = nil;
static FuncRegisterPlugins _registerPlugins = nil;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  @synchronized (self) {
    if (instance == nil) {
      instance = [[FltWorkerPlugin alloc] init];
//      [registrar addApplicationDelegate:instance];
    }
  }
  
  // channel for api calls should be registerd for both instances of engine,
  // so that it's available in the headless isolate
  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@PLUGIN_PKG
                                                              binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

+ (FuncRegisterPlugins) registerPlugins {
  return _registerPlugins;
}

+ (void) setRegisterPlugins:(FuncRegisterPlugins)registerPlugins {
  _registerPlugins = registerPlugins;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    // init a headless engine instance for callback
    _headlessEngine = [[FlutterEngine alloc] initWithName:@"flt_worker_isolate"
                                                  project:nil
                                   allowHeadlessExecution:YES];

    // channel for callbacks
    _callbackChannel = [FlutterMethodChannel methodChannelWithName:@"dev.thinkng.flt_worker/callback"
                                                   binaryMessenger:_headlessEngine];

    // register BGTask handler
    [self registerBGTaskHandler];
  }
  return self;
}

// register background task indentifier/handler pairs
- (void)registerBGTaskHandler {
  NSArray *bgTaskIds = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BGTaskSchedulerPermittedIdentifiers"];
  for (NSString *taskId in bgTaskIds) {
    [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:taskId
                                                          usingQueue:nil
                                                       launchHandler:^(BGTask *task) {
      [self launchTask:task];
    }];
  }
}

- (void)launchTask:(BGTask*)task {
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  queue.maxConcurrentOperationCount = 1;
  
  NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
    NSLog(@"start executing task %@", task.identifier);
  }];
  [queue addOperation:operation];
  
  task.expirationHandler = ^{
    [queue cancelAllOperations];
  };
  queue.operations.lastObject.completionBlock = ^{
    [task setTaskCompletedWithSuccess:YES];
  };
}

/** Start a headless engine instance with the entry handle */
- (void)startCallbackDispatcher:(int64_t)handle {
  FlutterCallbackInformation *cbInfo = [FlutterCallbackCache lookupCallbackInformation:handle];
  if (cbInfo == nil) {
    NSLog(@"callback not found for handle: %lld", handle);
    return;
  }
  
  [_headlessEngine runWithEntrypoint:cbInfo.callbackName libraryURI:cbInfo.callbackLibraryPath];
  if (!_isHeadlessEnginRegistered) {
    _registerPlugins(_headlessEngine);
    _isHeadlessEnginRegistered = YES;
  }
}

/** Dispatch a callback function call */
- (void)dispatchCallback:(int64_t)handle {
  [_callbackChannel invokeMethod:@API_METHOD(dispatch) arguments:@[@(handle)]];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *method = call.method;
  NSArray *args = call.arguments;
  if ([@API_METHOD(initialize) isEqualToString:method]) {
    if (args.count > 0) {
      [self startCallbackDispatcher:[args[0] longValue]];
    } else {
      NSLog(@"A callback argument is required by initialize method!");
    }
    result(nil);
  } else if ([@API_METHOD(test) isEqualToString:method]) {
    [self dispatchCallback:[args[0] longValue]];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
