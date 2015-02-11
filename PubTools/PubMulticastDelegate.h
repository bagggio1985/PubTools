//
//  PubMulticastDelegate.h
//  BeautyPie
//
//  Created by kyao on 15-1-26.
//  Copyright (c) 2015年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PubMulticastDelegate : NSObject

+ (instancetype)sharedMulticastDelegate;

/// selector 支持0或者1个NSString参数的方法
/// 最后事件的分发是在主线程中
/// 原则上不需要对deletgate进行remove，delegate==nil的时候会自动删除SEL
- (void)addDelegate:(id)delegate selector:(SEL)selector relatedEvent:(NSString*)event;
- (void)removeDelegate:(id)delegate relatedEvent:(NSString*)event;

- (void)dispatchEvent:(NSString*)event;
- (void)dispatchEvent:(NSString*)event withObject:(id)object;

@end
