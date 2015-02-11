//
//  NSDictionary+Helper.h
//  PubTools
//
//  Created by kyao on 14-12-15.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Helper)

@end

@interface NSMutableDictionary (Helper)

- (void)setObjectSafe:(id)object forKey:(NSString*)key;

@end

@interface NSArray (Helper)

- (id)objectAtIndexSafe:(NSUInteger)index;

@end
