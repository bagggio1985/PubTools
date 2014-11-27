//
//  GlobalConfig.h
//  PubTools
//
//  Created by kyao on 14-9-1.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kGlobalConfigDefault = 0, // do not use this key
    
    //Global Key
    
    kGlobalConfigCount
} kGlobalConfigKey;

/// change this key, should change s_configKey value in GlobalConfig.m
@interface GlobalConfig : NSObject

+ (GlobalConfig*)sharedConfig;

- (id)objectForKey:(kGlobalConfigKey)key;
- (void)setObject:(id)value forKey:(kGlobalConfigKey)key;

// default is NO; it will save when value changed if set YES
- (void)autoSync:(BOOL)sync;
- (void)synchronize;

@end
