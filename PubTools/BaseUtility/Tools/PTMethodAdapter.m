//
//  PTMethodAdapter.m
//
//  Created by kyao on 15/12/25.
//  Copyright © 2015年 mac. All rights reserved.
//

#import "PTMethodAdapter.h"

@implementation PTMethodAdapter

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.dest respondsToSelector:aSelector]) return YES;
    if ([self.source respondsToSelector:aSelector]) return YES;
    
    return [super respondsToSelector:aSelector];
}

- (instancetype)initWithSource:(id)sourceDelegate dest:(id)dest {
    if (self = [super init]) {
        self.source = sourceDelegate;
        self.dest = dest;
    }
    
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.dest respondsToSelector:aSelector]) {
        return self.dest;
    }
    if ([self.source respondsToSelector:aSelector]) {
        return self.source;
    }
    return self;
}

@end
