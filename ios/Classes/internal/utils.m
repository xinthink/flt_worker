//
//  utils.m
//  flt_worker
//
//  Created by Yingxin Wu on 2020/3/13.
//

#import "utils.h"

const NSString *_lock = @"";

NSUserDefaults *_workerDefaults = nil;
NSUserDefaults* workerDefaults() {
  @synchronized (_lock) {
    if (_workerDefaults == nil) {
      _workerDefaults = [[NSUserDefaults alloc] init];
    }
    return _workerDefaults;
  }
}

int64_t dispatcherHandle() {
  return [[workerDefaults() objectForKey:@DISPATCHER_KEY] longValue] ?: 0;
}

int64_t workerHandle() {
  return [[workerDefaults() objectForKey:@WORKER_KEY] longValue] ?: 0;
}
