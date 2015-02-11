//
//  NSDictionary+Helper.m
//  PubTools
//
//  Created by kyao on 14-12-15.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import "NSDictionary+Helper.h"

@implementation NSDictionary (Helper)

@end


@implementation NSMutableDictionary (Helper)

- (void)setObjectSafe:(id)object forKey:(NSString*)key {
    if (nil ==  object || nil == key) return ;
    
    [self setObject:object forKey:key];
}

@end

@implementation NSArray (Helper)

- (id)objectAtIndexSafe:(NSUInteger)index {
    id ret = nil;
    @try {
        ret = [self objectAtIndex:index];
    }
    @catch (NSException *exception) {
        ret = nil;
    }
    @finally {
        return ret;
    }
}

@end