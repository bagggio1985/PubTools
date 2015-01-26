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
- (void)addDelegate:(id)delegate selector:(SEL)selector relatedEvent:(NSString*)event;
- (void)removeDelegate:(id)delegate relatedEvent:(NSString*)event;

- (void)dispatchEvent:(NSString*)event;

@end
