#import "FltWorkerPlugin.h"
#import <BackgroundTasks/BackgroundTasks.h>

#define PLUGIN_PKG "dev.thinkng.flt_worker"
#define API_METHOD(NAME) "FltWorkerPlugin#"#NAME
#define WORK_KEY(id) [NSString stringWithFormat:@"dev.thinkng.flt_worker/works/%@", id]
#define IS_NONNULL(V) V && ![NSNull.null isEqual:V]

@implementation FltWorkerPlugin {
  FlutterEngine *_headlessEngine;
  FlutterMethodChannel *_callbackChannel;
  BOOL _isHeadlessEnginRegistered;
  NSUserDefaults *_userDefaults;
  NSDictionary *_workers;
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
    _userDefaults = [[NSUserDefaults alloc] init];

    // init a headless engine instance for callback
    _headlessEngine = [[FlutterEngine alloc] initWithName:@"flt_worker_isolate"
                                                  project:nil
                                   allowHeadlessExecution:YES];

    // channel for callbacks
    _callbackChannel = [FlutterMethodChannel methodChannelWithName:@PLUGIN_PKG"/callback"
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
    [BGTaskScheduler.sharedScheduler registerForTaskWithIdentifier:taskId
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
    NSLog(@"start executing task: %@", task);
    id work = [_userDefaults objectForKey:WORK_KEY(task.identifier)];
    if (work) {
      id rawHandle = [work objectForKey:@"callback"];
      if (IS_NONNULL(rawHandle)) {
        [self dispatchCallback:[rawHandle longValue]];
      }
    }
  }];
  [queue addOperation:operation];
  
  task.expirationHandler = ^{
    [queue cancelAllOperations];
  };
  queue.operations.lastObject.completionBlock = ^{
    [_userDefaults removeObjectForKey:WORK_KEY(task.identifier)];
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
  } else if (![self handleBGTasksMethodCall:call result:result]) {
    result(FlutterMethodNotImplemented);
  }
}

// handle method calls specific for `BackgroundTasks`
- (BOOL)handleBGTasksMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  BOOL handled = YES;
  NSString *method = call.method;
  id args = call.arguments;
  if ([@API_METHOD(submitTaskRequest) isEqualToString:method]) {
    BGTaskRequest *req = [self parseTaskRequest:args[0]];
    BOOL submitted = [BGTaskScheduler.sharedScheduler submitTaskRequest:req error:nil];
    [self saveWorkData:req args:args];
    if (submitted) {
      [self saveWorkData:req args:args];
    }
    result(@(submitted));
  } else if ([@API_METHOD(cancelTaskRequest) isEqualToString:method]) {
    [BGTaskScheduler.sharedScheduler cancelTaskRequestWithIdentifier:call.arguments[@"identifier"]];
    result(nil);
  } else if ([@API_METHOD(cancelAllTaskRequests) isEqualToString:method]) {
    [BGTaskScheduler.sharedScheduler cancelAllTaskRequests];
    result(nil);
  } else {
    handled = NO;
  }
  
  return handled;
}

- (BGTaskRequest*)parseTaskRequest:(id)arguments {
  BGTaskRequest *req;
  NSString *type = arguments[@"type"];
  NSString *identifier = arguments[@"identifier"];
  NSNumber *date = arguments[@"earliestBeginDate"];
  NSDate *earliestBeginDate = nil;
  if (IS_NONNULL(date)) {
    earliestBeginDate = [NSDate dateWithTimeIntervalSince1970:(date.doubleValue / 1000.0)];
  }
  
  if ([type isEqual:@"Processing"]) {
    BGProcessingTaskRequest *processReq = [[BGProcessingTaskRequest alloc] initWithIdentifier:identifier];
    req = processReq;
    
    id power = arguments[@"requiresExternalPower"];
    if (IS_NONNULL(power)) {
      processReq.requiresExternalPower = [power boolValue];
    }
    
    id network = arguments[@"requiresNetworkConnectivity"];
    if (IS_NONNULL(network)) {
      processReq.requiresNetworkConnectivity = [network boolValue];
    }
  } else {
    BGAppRefreshTaskRequest *refreshReq = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:identifier];
    req = refreshReq;
  }
  
  req.earliestBeginDate = earliestBeginDate;
  return req;
}

- (void)saveWorkData:(BGTaskRequest*)req args:(id)args {
  NSMutableDictionary *work = [[NSMutableDictionary alloc] init];
  if ([args count] > 1) {
    [work setObject:args[1] forKey:@"callback"];
  }
  [_userDefaults setObject:work forKey:WORK_KEY(req.identifier)];
}
@end
