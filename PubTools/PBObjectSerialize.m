//
//  PBObjectCoding.m
//  ViewSwitch
//
//  Created by kyao on 14-4-1.
//
//

#import "PBObjectSerialize.h"
#import <objc/runtime.h>

@implementation PBObjectSerialize

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        
        Class currentClass = object_getClass(self);
        [self decode:aDecoder class:currentClass];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    Class currentClass = object_getClass(self);
    [self encode:aCoder class:currentClass];
}

- (NSString*)getEncodeName:(NSString*)propetyName {
    const char* name = object_getClassName(self);
    return [[NSString stringWithUTF8String:name] stringByAppendingFormat:@"_%@", propetyName];
}

- (void)decode:(NSCoder*)aDecoder class:(Class)curClass {
    const char* className = class_getName(curClass);
    if (strcasecmp(className, "PBObjectSerialize") == 0) {
        // 已经调至当前基类里面了，不能在继续查询了
        return ;
    }
    
    unsigned int count = 0;
    objc_property_t* list = class_copyPropertyList(curClass, &count);
    for (unsigned int idx = 0; idx < count; idx++) {
        objc_property_t property = list[idx];
        
        const char* name = property_getName(property);
        NSString* propertyName = [NSString stringWithUTF8String:name];
        if ([propertyName length] == 0) continue;
        
        if ([self isInnerProperty:propertyName]) continue;
        
        id value = [aDecoder decodeObjectForKey:[self getEncodeName:propertyName]];
        if (value) {
            [self setValue:value forKey:propertyName];
        }
    }
    // delete malloc memory
    if (list) free(list);
    
    Class superClass = class_getSuperclass(curClass);
    if (superClass) {
        [self decode:aDecoder class:superClass];
    }
}

// 兼容IOS8-XCODE6
- (BOOL)isInnerProperty:(NSString*)propertyName {
    // primaryKey | rowid
    if ([propertyName isEqualToString:@"hash"]|| [propertyName isEqualToString:@"superclass"]|| [propertyName isEqualToString:@"description"] || [propertyName isEqualToString:@"debugDescription"]) {
        return YES;
    }
    
    return NO;
}

- (void)encode:(NSCoder*)aDecoder class:(Class)curClass {
    const char* className = class_getName(curClass);
    if (strcasecmp(className, "PBObjectSerialize") == 0) {
        // 已经调至当前基类里面了，不能在继续查询了
        return ;
    }
    
    unsigned int count = 0;
    objc_property_t* list = class_copyPropertyList(curClass, &count);
    for (unsigned int idx = 0; idx < count; idx++) {
        objc_property_t property = list[idx];
        
        const char* name = property_getName(property);
        NSString* propertyName = [NSString stringWithUTF8String:name];
        if ([propertyName length] == 0) continue;
        if ([self isInnerProperty:propertyName]) continue;
        
        id value = [self valueForKey:propertyName];
        [aDecoder encodeObject:value forKey:[self getEncodeName:propertyName]];
    }
    // delete malloc memory
    if (list) free(list);
    
    Class superClass = class_getSuperclass(curClass);
    if (superClass) {
        [self encode:aDecoder class:superClass];
    }
}

@end
