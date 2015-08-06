//
//  PBDataModel.m
//
//  Created by kyao on 15/7/27.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "PBDataModel.h"
#import <objc/runtime.h>
#import "FMDatabase.h"

#if DEBUG

#ifndef DEBUG_NSAssert
#define DEBUG_NSAssert NSAssert
#endif

#else

#ifndef DEBUG_NSAssert
#define DEBUG_NSAssert
#endif

#endif

@implementation PBBaseModel

#pragma mark - Public

+ (NSString*)tableName {
    return NSStringFromClass([self class]);
}

+ (NSDictionary*)tableKeyMapping {
    return nil;
}

+ (NSString *)createTableSQL {
    return nil;
}

+ (instancetype)modelWithResult:(FMResultSet*)result {
    PBBaseModel* model = [[[self class] alloc] init];
    [model decode:result class:[self class]];
    return model;
}

+ (instancetype)modelWithMultiResult:(FMResultSet*)result {
    PBBaseModel* model = [[[self class] alloc] init];
    [model decodeForMulti:result class:[self class]];
    return model;
}

+ (FMResultSet*)query:(FMDatabase*)db queryKey:(NSArray*)keys where:(NSString*)where others:(NSString*)others argumentAry:(NSArray*)argumentAry {

    DEBUG_NSAssert([self canFitStaments:where argsCount:[argumentAry count]], @"statements not fit the argumentAry count!");

    NSMutableString* sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"select %@ from %@", [self getSelectedVolume:keys], [[self class] tableName]];
    
    FMResultSet* result = nil;
    if ([where length]) {
        [sql appendFormat:@" where %@ %@", where, others ? : @""];
        
        result = [db executeQuery:sql withArgumentsInArray:argumentAry];
    }
    else {
        if (others) {
            [sql appendFormat:@" %@", others];
        }
        result = [db executeQuery:sql];
    }
    
    return result;
}

+ (NSArray*)queryAndParse:(FMDatabase*)db queryKey:(NSArray*)keys where:(NSString*)where others:(NSString*)others argumentAry:(NSArray*)argumentAry {
    FMResultSet* resultSet = [self query:db queryKey:keys where:where others:others argumentAry:argumentAry];
    NSMutableArray* array = [NSMutableArray array];
    while ([resultSet next]) {
        [array addObject:[self modelWithResult:resultSet]];
    }
    [resultSet close];
    
    return array;
}

+ (FMResultSet*)query:(FMDatabase*)db queryKey:(NSArray*)tableKeys relationTables:(NSArray*)relationTables where:(NSString *)where others:(NSString *)others argumentAry:(NSArray *)argumentAry {
    DEBUG_NSAssert([tableKeys count], @"tableKeys must have more than one keys");
    DEBUG_NSAssert([tableKeys count] == [relationTables count] || [tableKeys count] == ([relationTables count] + 1), @"query table count is not right!");
    
    // 重置关联表数组
    if ([tableKeys count] == [relationTables count] + 1) {
        NSMutableArray* realAry = [[NSMutableArray alloc] initWithObjects:[self class], nil];
        [realAry addObjectsFromArray:relationTables];
        relationTables = realAry;
    }
    
    NSMutableString* sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"select %@ from %@", [self getMultiSelectVolume:tableKeys tables:relationTables], [self getMultiSelectTables:relationTables]];
    
    if ([where length]) {
        [sql appendFormat:@" where %@ %@", where, others ? : @""];
    }
    else {
        [sql appendFormat:@" %@", others ? : @""];
    }
    
    return [db executeQuery:sql withArgumentsInArray:argumentAry];
}

- (int64_t)insert:(FMDatabase*)db insertKey:(NSArray*)keys {
    NSMutableString* sql = [[NSMutableString alloc] init];
    if ([keys count] == 0) {
        keys = [self getValuedVolume];
    }
    
    NSAssert([keys count] > 0, @"no insert keys");
    
    [sql appendFormat:@"insert into %@ (%@) values (%@)", [[self class] tableName], [[self class] getSelectedVolume:keys], [self getArguments:[keys count]]];
    
    BOOL ok = [db executeUpdate:sql withArgumentsInArray:[self getArgumentsValue:keys]];
    
    if (ok) return [db lastInsertRowId];
    
    return -1;
}

- (int64_t)insertOrReplace:(FMDatabase*)db insertKey:(NSArray*)keys {
    NSMutableString* sql = [[NSMutableString alloc] init];
    if ([keys count] == 0) {
        keys = [self getValuedVolume];
    }
    
    DEBUG_NSAssert([keys count] > 0, @"no insert key, error");
    
    [sql appendFormat:@"insert or replace into %@ (%@) values (%@)", [[self class] tableName], [[self class] getSelectedVolume:keys], [self getArguments:[keys count]]];
    
    BOOL ok = [db executeUpdate:sql withArgumentsInArray:[self getArgumentsValue:keys]];
    
    if (ok) return [db lastInsertRowId];
    
    return -1;
}

- (BOOL)ignoreKeyWhenInsert:(NSString*)keyName {
    return NO;
}

- (BOOL)update:(FMDatabase*)db keys:(NSArray*)keys where:(NSString*)where argumentAry:(NSArray*)argumentAry {
    if ([keys count] == 0) {
        keys = [[self class] getAllDBKeys];
    }
    
    NSMutableString* sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"update %@ set %@", [[self class] tableName], [self getUpdateSetKey:keys]];
    if ([where length]) {
        [sql appendFormat:@" where %@", where];
    }
    
    return [db executeUpdate:sql withArgumentsInArray:[self getTotalUpateArgs:keys sourceArgs:argumentAry]];
}

#pragma mark - Private Delete

+ (BOOL)deleteObject:(FMDatabase*)db where:(NSString*)where argumentAry:(NSArray*)argumentAry {
    NSMutableString* sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"delete from %@", [[self class] tableName]];
    if ([where length]) {
        [sql appendFormat:@" where %@", where];
    }
    
    return [db executeUpdate:sql withArgumentsInArray:argumentAry];
}

+ (NSArray*)getAllDBKeys {
    return [self getInnerAllKeys:[self class]];
}

+ (NSArray*)getDBKeysExcept:(NSArray*)keys {
    NSArray* allDBKeys = [self getAllDBKeys];
    NSMutableArray* mutableKeys = [NSMutableArray arrayWithArray:allDBKeys];
    [mutableKeys removeObjectsInArray:keys];
    return mutableKeys;
}

+ (NSSet*)notDBKeys {
    return nil;
}

+ (NSArray*)getAllProperty:(Class)classType {
    
    NSMutableArray* retAry = [NSMutableArray new];
    unsigned int count = 0;
    objc_property_t* list = class_copyPropertyList(classType, &count);
    for (unsigned int idx = 0; idx < count; idx++) {
        objc_property_t property = list[idx];
        
        const char* name = property_getName(property);
        NSString* propertyName = [NSString stringWithUTF8String:name];
        if ([propertyName length] == 0) continue;
        
        if ([self isInnerProperty:propertyName]) continue;
        
        [retAry addObject:propertyName];
    }
    // delete malloc memory
    if (list) free(list);
    
    return retAry;
}

#pragma mark - Private Update

- (NSString*)getUpdateSetKey:(NSArray*)keys {
    NSMutableArray* ary = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString* key in keys) {
        [ary addObject:[NSString stringWithFormat:@"%@ = ?", [[self class] getTransformName:key]]];
    }
    
    return [ary componentsJoinedByString:@","];
}

- (NSArray*)getTotalUpateArgs:(NSArray*)keys sourceArgs:(NSArray*)sourceArgs {
    NSMutableArray* ary = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString* property in keys) {
        id value = [self valueForKey:property];
        if ([value isKindOfClass:[NSNumber class]] ||
            [value isKindOfClass:[NSDate class]] ||
            [value isKindOfClass:[NSString class]]
            ) {
            if (value) {
                [ary addObject:value];
            }
            else {
                [ary addObject:@""];
            }
        }
        else {
            DEBUG_NSAssert(0, @"not support property value");
            [ary addObject:@""];
        }
    }
    
    [ary addObjectsFromArray:sourceArgs];
    
    return ary;
}

#pragma mark - Private Insert

- (NSString*)getArguments:(NSUInteger)count {
    NSMutableArray *ary = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger index = 0; index < count; index++) {
        [ary addObject:@"?"];
    }
    return [ary componentsJoinedByString:@","];
}

- (NSArray*)getArgumentsValue:(NSArray*)keys {
    NSMutableArray* ary = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString* property in keys) {
        id value = [self valueForKey:property];
        if ([value isKindOfClass:[NSNumber class]] ||
            [value isKindOfClass:[NSDate class]] ||
            [value isKindOfClass:[NSString class]]
            ) {
            [ary addObject:value];
        }
        else {
            DEBUG_NSAssert(0, @"not support property value");
        }
    }
    
    return ary;
}

- (NSArray*)getValuedVolume {
    return [self getValuedVolume:[self class]];
}

- (NSArray*)getValuedVolume:(Class)curClass {
    const char* className = class_getName(curClass);
    if (strcasecmp(className, [NSStringFromClass([PBBaseModel class]) UTF8String]) == 0) return nil;
    
    NSMutableArray* retAry = [NSMutableArray new];
    unsigned int count = 0;
    objc_property_t* list = class_copyPropertyList(curClass, &count);
    for (unsigned int idx = 0; idx < count; idx++) {
        objc_property_t property = list[idx];
        
        const char* name = property_getName(property);
        NSString* propertyName = [NSString stringWithUTF8String:name];
        if ([propertyName length] == 0) continue;
        
        if ([self isInnerProperty:propertyName]) continue;
        if ([[[self class] notDBKeys] containsObject:propertyName]) continue;
        if ([self ignoreKeyWhenInsert:propertyName]) continue;
        
        const char *attrs = property_getAttributes(property);
        if (strcasestr(attrs, [NSStringFromProtocol(@protocol(KKTableOptionalKey)) cStringUsingEncoding:NSUTF8StringEncoding])) continue;
        
        id value = [self valueForKey:propertyName];
        if (value && ![value isKindOfClass:[NSNull class]]) {
            [retAry addObject:propertyName];
        }
    }
    // delete malloc memory
    if (list) free(list);
    
    Class superClass = class_getSuperclass(curClass);
    if (superClass) {
        [retAry addObjectsFromArray:[self getValuedVolume:superClass]];
    }
    
    return retAry;
}

#pragma mark - Private Select

+ (NSString*)getSelectedVolume:(NSArray*)keys {
    if ([keys count] == 0) return @"*";
    
    NSMutableArray* realArray = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString* key in keys) {
        [realArray addObject:[self getTransformName:key]];
    }
    return [realArray componentsJoinedByString:@","];
}

+ (NSString*)getMultiSelectVolume:(NSArray*)keys tables:(NSArray*)tables {
    NSMutableArray* tableKeys = [NSMutableArray new];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSArray* keysList = obj;
        
        if ([obj isKindOfClass:[NSNull class]]) {
            keysList = [[[tables objectAtIndex:idx] class] getAllDBKeys];
        }
        
        for (NSString* key in keysList) {
            NSString* keyName = [self getTransformName:key class:[tables objectAtIndex:idx]];
            [tableKeys addObject:[NSString stringWithFormat:@"%c.%@ as %@_%@", (char)(idx+'a'), keyName, [[tables objectAtIndex:idx] tableName], keyName]];
        }
        
    }];
    return [tableKeys componentsJoinedByString:@","];
}

+ (NSString*)getMultiSelectTables:(NSArray*)tables {
    NSMutableArray* tablesName = [NSMutableArray new];
    [tables enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Class curClass = obj;
        [tablesName addObject:[NSString stringWithFormat:@"%@ %c", [curClass tableName], (char)(idx+'a')]];
    }];
    return [tablesName componentsJoinedByString:@","];
}

#pragma mark - Private Key Runtime

- (void)decode:(FMResultSet*)result class:(Class)curClass {
    const char* className = class_getName(curClass);
    if (strcasecmp(className, [NSStringFromClass([PBBaseModel class]) UTF8String]) == 0) return ;
    
    unsigned int count = 0;
    objc_property_t* list = class_copyPropertyList(curClass, &count);
    for (unsigned int idx = 0; idx < count; idx++) {
        objc_property_t property = list[idx];
        
        const char* name = property_getName(property);
        NSString* propertyName = [NSString stringWithUTF8String:name];
        if ([propertyName length] == 0) continue;
        
        if ([self isInnerProperty:propertyName]) continue;
        
        NSString* keyName = [[self class] getTransformName:propertyName];
        id value = [result objectForColumnName:keyName];
        if (value && ![value isKindOfClass:[NSNull class]]) {
            [self setValue:value forKey:propertyName];
        }
    }
    // delete malloc memory
    if (list) free(list);
    
    Class superClass = class_getSuperclass(curClass);
    if (superClass) {
        [self decode:result class:superClass];
    }
}

- (void)decodeForMulti:(FMResultSet*)result class:(Class)curClass {
    const char* className = class_getName(curClass);
    if (strcasecmp(className, [NSStringFromClass([PBBaseModel class]) UTF8String]) == 0) return ;
    
    unsigned int count = 0;
    objc_property_t* list = class_copyPropertyList(curClass, &count);
    for (unsigned int idx = 0; idx < count; idx++) {
        objc_property_t property = list[idx];
        
        const char* name = property_getName(property);
        NSString* propertyName = [NSString stringWithUTF8String:name];
        if ([propertyName length] == 0) continue;
        
        if ([self isInnerProperty:propertyName]) continue;
        
        NSString* keyName = [[self class] getTransformName:propertyName];
        keyName = [NSString stringWithFormat:@"%@_%@", [[self class] tableName], keyName];
        id value = [result objectForColumnName:keyName];
        if (value && ![value isKindOfClass:[NSNull class]]) {
            [self setValue:value forKey:propertyName];
        }
    }
    // delete malloc memory
    if (list) free(list);
    
    Class superClass = class_getSuperclass(curClass);
    if (superClass) {
        [self decodeForMulti:result class:superClass];
    }
}

+ (NSString*)getTransformName:(NSString*)propetyName {
    NSString* realName = [[self tableKeyMapping] objectForKey:propetyName];
    return realName ? realName : propetyName;
}

+ (NSString*)getTransformName:(NSString*)propetyName class:(Class)class {
    NSString* realName = [[class tableKeyMapping] objectForKey:propetyName];
    return realName ? realName : propetyName;
}

+ (BOOL)isInnerProperty:(NSString*)propertyName {
    // primaryKey | rowid
    if ([propertyName isEqualToString:@"hash"]|| [propertyName isEqualToString:@"superclass"]|| [propertyName isEqualToString:@"description"] || [propertyName isEqualToString:@"debugDescription"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isInnerProperty:(NSString*)propertyName {
    return [[self class] isInnerProperty:propertyName];
}

+ (NSArray*)getInnerAllKeys:(Class)curClass {
    const char* className = class_getName(curClass);
    if (strcasecmp(className, [NSStringFromClass([PBBaseModel class]) UTF8String]) == 0) return nil;
    
    NSMutableArray* retAry = [NSMutableArray new];
    unsigned int count = 0;
    objc_property_t* list = class_copyPropertyList(curClass, &count);
    for (unsigned int idx = 0; idx < count; idx++) {
        objc_property_t property = list[idx];
        
        const char* name = property_getName(property);
        NSString* propertyName = [NSString stringWithUTF8String:name];
        if ([propertyName length] == 0) continue;
        
        if ([self isInnerProperty:propertyName]) continue;
        if ([[self notDBKeys] containsObject:propertyName]) continue;
        
        // 过滤掉不是数据库字段的key
        [retAry addObject:propertyName];
    }
    // delete malloc memory
    if (list) free(list);
    
    Class superClass = class_getSuperclass(curClass);
    if (superClass) {
        [retAry addObjectsFromArray:[self getInnerAllKeys:superClass]];
    }
    
    return retAry;
}

+ (BOOL)canFitStaments:(NSString*)where argsCount:(NSInteger)count {
    NSInteger charCount = 0;
    for (int index = 0; index < where.length; index++) {
        unichar character = [where characterAtIndex:index];
        if (character == '?') {
            charCount++;
        }
    }
    
    return (charCount == count);
}

@end
