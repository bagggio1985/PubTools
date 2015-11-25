//
//  PTLock.m
//  PubTools
//
//  Created by kyao on 15/11/11.
//  Copyright © 2015年. All rights reserved.
//

#import "PTLock.h"
#import <libkern/OSAtomic.h>

@interface PTLock () {
    dispatch_semaphore_t _semaphore;
}

@end

@implementation PTLock

- (instancetype)init {
    if (self = [super init]) {
        _semaphore = dispatch_semaphore_create(1);
    }
    
    return self;
}

- (void)lock {
    if (_semaphore) {
        dispatch_semaphore_wait(_semaphore , DISPATCH_TIME_FOREVER);
    }
}

- (void)unlock {
    if (_semaphore) {
        dispatch_semaphore_signal(_semaphore);
    }
}

@end

@interface PTSpinLock () {
    OSSpinLock _lock;
}

@end

@implementation PTSpinLock

- (instancetype)init {
    if (self = [super init]) {
        _lock = OS_SPINLOCK_INIT;
    }
    
    return self;
}

- (void)lock {
    OSSpinLockLock(&_lock);
}

- (void)unlock {
    OSSpinLockUnlock(&_lock);
}

- (BOOL)tryLock {
    return OSSpinLockTry(&_lock) ? YES : NO;
}

@end

@interface PTAutoLock () {
    PTLock* _lock;
}

@end

@implementation PTAutoLock

- (instancetype)initWithLock:(PTLock *)lock {
    if (self = [super init]) {
        _lock = lock;
    }
    
    return self;
}

- (void)dealloc {
    if (_lock) {
        [_lock unlock];
        _lock = nil;
    }
}

@end
