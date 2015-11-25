//
//  KKChatStorage.m
//
//  Created by kyao on 15/7/27.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "PBDataStorage.h"

@interface PBDBVersion : PBBaseModel

@property (nonatomic, assign) int32_t version;

+ (NSString*)updateVersion:(int32_t)version;
+ (NSString*)versionInDB;

@end

@implementation PBDBVersion

+ (NSString*)tableName {
    return @"DatabaseVesion";
}

+ (NSString *)createTableSQL {
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (version INTEGER PRIMARY KEY)", [self tableName]];
}

+ (NSString*)updateVersion:(int32_t)version {
    return [NSString stringWithFormat:@"delete from %@;insert or replace into %@ (version) values (%d)", [self tableName], [self tableName], version];
}

+ (NSString *)versionInDB {
    return [NSString stringWithFormat:@"select version from %@ limit 1", [self tableName]];
}

@end

const static int s_curDBVersion = 1;

@interface PBDataStorage ()

@end

@implementation PBDataStorage

+ (instancetype)sharedStorage {
    
    static PBDataStorage* storage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[self alloc] init];
    });
    
    return storage;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    
    return self;
}

- (NSArray*)registerTableArray {
    return nil;
}

- (void)nowDbVersion:(NSInteger)orginal {    
    if (orginal != s_curDBVersion) {
        [self setDbVersion:s_curDBVersion];
    }
}

- (void)setDbVersion:(NSInteger)version {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeStatements:[PBDBVersion updateVersion:(int32_t)version]];
    }];
}

#pragma mark Private
- (void)commonInit {
    [self initDatabase];
    [self createDataTable];
    [self nowDbVersion:[self getDbVersion]];
}

- (void)initDatabase {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:@"chat.sqlite"];
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
}

- (void)createDataTable {
    NSMutableArray *sqlAry = [NSMutableArray arrayWithObject:[PBDBVersion createTableSQL]];
    for (Class class in [self registerTableArray]) {
        if (![class isSubclassOfClass:[PBBaseModel class]]) continue ;
        NSString* sql = [class createTableSQL];
        [sqlAry addObject:sql];
    }
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString* sql in sqlAry) {
            [db executeStatements:sql];
        }
    }];
}

- (NSInteger)getDbVersion {
    __block int version = 0;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:[PBDBVersion versionInDB]];
        if ([result next]) {
            PBDBVersion* chatVersion = [PBDBVersion modelWithResult:result];
            version = chatVersion.version;
        }
        [result close];
    }];
    
    return version;
}

- (NSArray*)instanceArrayByResult:(Class)classType result:(FMResultSet*)resultSet {
    NSAssert([classType isSubclassOfClass:[PBBaseModel class]] , @"class must be equal or subclass of PBBaseModel");
    if (resultSet == nil) return nil;
    
    NSMutableArray* insAry = [NSMutableArray new];
    while ([resultSet next]) {
        [insAry addObject:[classType modelWithResult:resultSet]];
    }
    
    [resultSet close];
    
    return insAry;
}

@end
