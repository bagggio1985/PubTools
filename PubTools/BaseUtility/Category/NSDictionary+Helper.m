//
//  NSDictionary+Helper.m
//  PubTools
//
//  Created by kyao on 14-12-15.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "NSDictionary+Helper.h"

@implementation NSDictionary (Helper)

- (id)safeObjectForKey:(id)key {
    if (!key) return nil;
    
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSNull class]]) return nil;
    
    return value;
}

- (int)intForKey:(id)key {
    id value = [self safeObjectForKey:key];
    
    if ([value respondsToSelector:@selector(intValue)])
        return [value intValue];
    
    return 0;
    
}

- (double)doubleForKey:(id)key {
    id value = [self safeObjectForKey:key];
    
    if ([value respondsToSelector:@selector(doubleValue)])
        return [value doubleValue];
    
    return 0.f;
}

- (NSString*)stringForKey:(id)key {
    id value = [self safeObjectForKey:key];
    
    if ([value isKindOfClass:[NSString class]]) return value;
    
    if ([value respondsToSelector:@selector(stringValue)])
        return [value stringValue];
    
    return nil;
}

@end


@implementation NSMutableDictionary (Helper)

- (void)setObjectSafe:(id)object forKey:(id)key {
    if (nil ==  object || nil == key) return ;
    
    [self setObject:object forKey:key];
}

- (void)setInt:(int)value forKey:(id)key {
    [self setObject:@(value) forKey:key];
}

- (void)setDouble:(double)value forKey:(id)key {
    [self setObject:@(value) forKey:key];
}

@end

@implementation NSDictionary (Json)

- (NSString*)jsonString {
    NSData* infoJsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:infoJsonData encoding:NSUTF8StringEncoding];
}

+ (instancetype)dictionaryWithJsonString:(NSString*)json {
    return [self dictionaryWithJsonData:[json dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (instancetype)dictionaryWithJsonData:(NSData*)json {
    if (!json) return nil;
    
    id value = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
    if ([value isKindOfClass:[NSDictionary class]]) return value;
    
    return nil;
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