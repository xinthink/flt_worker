//
//  BGTaskMgrDelegate.m
//  flt_worker
//
//  Created by Yingxin Wu on 2020/3/12.
//

#import "BGTaskMgrDelegate.h"
#import "BGTaskHandler.h"
#import "utils.h"
#import <BackgroundTasks/BackgroundTasks.h>

//#ifdef DEBUG
//#import <objc/runtime.h>
//#import <objc/message.h>
//#endif

@implementation BGTaskMgrDelegate

// register background task indentifier/handler pairs
+ (void)registerBGTaskHandler {
  NSArray *bgTaskIds = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BGTaskSchedulerPermittedIdentifiers"];
  for (NSString *taskId in bgTaskIds) {
    [BGTaskScheduler.sharedScheduler registerForTaskWithIdentifier:taskId
                                                        usingQueue:dispatch_get_main_queue()
                                                     launchHandler:^(BGTask * _Nonnull task) {
      [BGTaskHandler.instance handleBGTask:task];
    }];
  }
}
 
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _methodChannel = [FlutterMethodChannel methodChannelWithName:@PLUGIN_PKG
                                                 binaryMessenger:[registrar messenger]];
  }
  return self;
}

- (instancetype)initWithEngine:(FlutterEngine *)engine {
  self = [super init];
  if (self) {
    _methodChannel = [FlutterMethodChannel methodChannelWithName:@PLUGIN_PKG
                                                 binaryMessenger:[engine binaryMessenger]];
  }
  return self;
}

- (void)saveHandles:(NSArray *)args {
  if (args.count > 1) {
    [workerDefaults() setObject:args[0] forKey:@DISPATCHER_KEY];
    [workerDefaults() setObject:args[1] forKey:@WORKER_KEY];
  } else {
    NSLog(@"Dispatcher & Worker callbacks are required!");
  }
}

/** Caches an extra input data for the given task */
- (void)saveExtrasForTask:(NSString*)identifier extras:(NSString*)extras {
  [workerDefaults() setObject:extras forKey:TASK_KEY(identifier)];
}

/** Makes a payload dict used as input of the dart worker */
- (NSDictionary*)packPayloadForTask:(NSString*)identifier {
  return @{
    @"id": identifier,
    @"tags": @[identifier],
    @"input": @{
        @"data": [workerDefaults() objectForKey:TASK_KEY(identifier)],
    },
  };
}

- (BOOL)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  BOOL handled = YES;
  NSString *method = call.method;
  id args = call.arguments;
  if ([@API_METHOD(submitTaskRequest) isEqualToString:method]) {
    BGTaskRequest *req = [self parseTaskRequest:args];
    BOOL submitted = [BGTaskScheduler.sharedScheduler submitTaskRequest:req error:nil];
    result(@(submitted));
  } else if ([@API_METHOD(cancelTaskRequest) isEqualToString:method]) {
    [BGTaskScheduler.sharedScheduler cancelTaskRequestWithIdentifier:args];
    result(nil);
  } else if ([@API_METHOD(cancelAllTaskRequests) isEqualToString:method]) {
    [BGTaskScheduler.sharedScheduler cancelAllTaskRequests];
    result(nil);
  } else if ([@API_METHOD(simulateLaunchTask) isEqualToString:method]) {
    [self simulateLaunchTask:args];
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

  // parse & cache extra input data
  NSString *extras = arguments[@"input"];
  [self saveExtrasForTask:identifier extras:extras];
  return req;
}

/** Simulate launch BGTask with the given identifier, using reflection & private APIs, for debugging only */
- (void)simulateLaunchTask:(NSString*)identifier {
//#ifdef DEBUG
//  Method simulateMethod = nil;
//  SEL simulateSel = nil;
//  unsigned int numMethods = 0;
//  Method *methods = class_copyMethodList([BGTaskScheduler class], &numMethods);
//
//  for (int i = 0; i < numMethods; i++) {
//    SEL sel = method_getName(methods[i]);
//    const char *name = sel_getName(sel);
//    if (strcmp("_simulateLaunchForTaskWithIdentifier:", name) == 0) {
//      simulateMethod = methods[i];
//      simulateSel = sel;
//      break;
//    }
//  }
//
//  if (simulateMethod) {
//    // only works on simulator??
////    ((void (*)(id, SEL, ...))objc_msgSend)([BGTaskScheduler sharedScheduler], simulateSel, identifier);
////    ((void (*)(id, Method, ...))method_invoke)([BGTaskScheduler sharedScheduler], simulateMethod, identifier);
//  }
//  if (methods) {
//    free(methods);
//  }
//#endif
}

@end
