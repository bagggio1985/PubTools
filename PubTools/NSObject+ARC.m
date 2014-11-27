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
