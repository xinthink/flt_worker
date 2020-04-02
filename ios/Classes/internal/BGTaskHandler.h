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

@property (class, readonly) BGTaskHandler * _Nonnull instance;
@property (class, nonatomic) FuncRegisterPlugins _Nullable registerPlugins;

- (void)handleBGTask:(BGTask * _Nonnull)task API_AVAILABLE(ios(13.0));

@end

#endif /* BGTaskHandler_h */
