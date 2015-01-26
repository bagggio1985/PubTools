//
//  NSObject+ARC.m
//  PubTools
//
//  Created by kyao on 14-9-1.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import "NSObject+ARC.h"
#import <objc/runtime.h>

static NSMutableSet *s_allObjectsRelative = nil;

@implementation NSObject (ARC)

- (id)retainObject {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_allObjectsRelative = [[NSMutableSet alloc] init];
    });
    
    [s_allObjectsRelative addObject:self];
    
    return self;
}

- (void)releaseObject {
    [s_allObjectsRelative removeObject:self];
}

@end

@implementation NSObject (GCDSupport)

- (void)invokeAsyncMain:(dispatch_block_t)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            block();
        }
    });
}

- (void)invokeAsyncGlobal:(dispatch_block_t)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            block();
        }
    });
}

- (void)invokeSync:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                block();
            }
        });
    }
}

@end
