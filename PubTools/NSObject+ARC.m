//
//  NSObject+ARC.m
//  PubTools
//
//  Created by kyao on 14-9-1.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import "NSObject+ARC.h"
#import <objc/runtime.h>

static void * const kNSObjectAssociatedKey = (void*)&kNSObjectAssociatedKey;

@implementation NSObject (ARC)

- (id)retainObject {
    objc_setAssociatedObject(self, kNSObjectAssociatedKey, self, OBJC_ASSOCIATION_RETAIN);
    return self;
}

- (void)releaseObject {
    objc_setAssociatedObject(self, kNSObjectAssociatedKey, nil, OBJC_ASSOCIATION_RETAIN);
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
