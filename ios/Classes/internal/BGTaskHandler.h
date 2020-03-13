//
//  BGTaskHandler.h
//  Pods
//
//  Created by Yingxin Wu on 2020/3/13.
//

#ifndef BGTaskHandler_h
#define BGTaskHandler_h

#import "utils.h"
#import <BackgroundTasks/BackgroundTasks.h>

@interface BGTaskHandler : NSObject<FlutterPlugin>

@property (class, readonly) BGTaskHandler *instance;
@property (class, nonatomic) FuncRegisterPlugins registerPlugins;

- (void)handleBGTask:(BGTask * _Nonnull)task;

@end

#endif /* BGTaskHandler_h */
