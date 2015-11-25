//
//  PTLock.h
//  PubTools
//
//  Created by kyao on 15/11/11.
//  Copyright © 2015年. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTLock <NSObject>

- (void)lock;
- (void)unlock;

@end

@interface PTLock : NSObject <PTLock>

@end

@interface PTSpinLock : NSObject <PTLock>

- (BOOL)tryLock;

@end

@interface PTAutoLock : NSObject

/**
 *  初始化函数，在初始化函数里面加锁，被释放时解锁
 *
 *  @param lock PTLock，进行枷锁的对象
 *
 *  @return
 */
- (instancetype)initWithLock:(id<PTLock>)lock;

@end
