//
//  NSObject+ARC.h
//  PubTools
//
//  Created by kyao on 14-9-1.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 用于ARC环境中替代retain和release
@interface NSObject (ARC)

- (id)retainObject;
- (void)releaseObject;

@end

#define PubDispatchMain     dispatch_async(dispatch_get_main_queue(), ^{ @autoreleasepool {
#define PubDispatchGlobal   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ @autoreleasepool {
#define PubDispatchEnd }});

@interface NSObject (GCDSupport)

- (void)invokeAsyncMain:(dispatch_block_t)block;
- (void)invokeAsyncGlobal:(dispatch_block_t)block;
- (void)invokeSync:(dispatch_block_t)block;

@end
