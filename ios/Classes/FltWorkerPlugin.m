#import "FltWorkerPlugin.h"
#import <BackgroundTasks/BackgroundTasks.h>

@implementation FltWorkerPlugin

static FltWorkerPlugin *instance = nil;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  @synchronized (self) {
    if (instance == nil) {
      instance = [[FltWorkerPlugin alloc] init:registrar];
      [registrar addApplicationDelegate:instance];
    }
  }
}

- (instancetype)init:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
    _headlessEngine = [[FlutterEngine alloc] initWithName:@"flt_worker_isolate"
                                                  project:nil
                                   allowHeadlessExecution:YES];

    // channel for api call
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"dev.thinkng.flt_worker"
                                                                binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:self channel:channel];

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
  if (bgTaskIds.count > 0) {
    for (NSString *taskId in bgTaskIds) {
      [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:taskId
                                                            usingQueue:nil
                                                         launchHandler:^(BGTask *task) {
        [self launchTask:task];
      }];
    }
  }
}

- (void)launchTask:(BGTask*)task {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    NSLog(@"--- launchTask %@", task.identifier);
    
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"--- start executing task %@", task.identifier);
    }];
    [queue addOperation:operation];
    
    task.expirationHandler = ^{
        [queue cancelAllOperations];
    };
    queue.operations.lastObject.completionBlock = ^{
        [task setTaskCompletedWithSuccess:YES];
    };
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
