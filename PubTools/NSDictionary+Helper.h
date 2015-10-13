//
//  NSDictionary+Helper.h
//  PubTools
//
//  Created by kyao on 14-12-15.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Helper)

// 过滤掉NSNull类型
- (id)safeObjectForKey:(id)key;
- (int)intForKey:(id)key;
- (double)doubleForKey:(id)key;
- (NSString*)stringForKey:(id)key;

@end

@interface NSMutableDictionary (Helper)

- (void)setObjectSafe:(id)object forKey:(id)key;
- (void)setInt:(int)value forKey:(id)key;
- (void)setDouble:(double)value forKey:(id)key;

@end

@interface NSDictionary (Json)

+ (instancetype)dictionaryWithJsonString:(NSString*)json;
+ (instancetype)dictionaryWithJsonData:(NSData*)json;

- (NSString*)jsonString;

@end

@interface NSArray (Helper)

- (id)objectAtIndexSafe:(NSUInteger)index;

@end
