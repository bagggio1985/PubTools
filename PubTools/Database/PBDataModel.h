//
//  PBDataModel.h
//
//  Created by kyao on 15/7/27.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"

@protocol KKTableOptionalKey
@end

@interface PBBaseModel : NSObject

/**
 *  返回该类对应的数据库的表名，如果表名和类名相同，不需要重写该函数
 *
 *  @return 
 */
+ (NSString*)tableName;
/**
 *  在通过查询结果生成类的时候会调用该方法，如果表字段和类字段一直，不需要重写
 *
 *  @return 返回的是类的字段和表名的字段对应关系
 */
+ (NSDictionary*)tableKeyMapping;
/**
 *  返回创建数据库表结构的SQL语句
 *
 *  @return SQL
 */
+ (NSString*)createTableSQL;

+ (instancetype)modelWithResult:(FMResultSet*)result;
/**
 *  多表查询的时候使用该方法生成对应的实例
 *
 *  @param result
 *
 *  @return
 */
+ (instancetype)modelWithMultiResult:(FMResultSet*)result;

/**
 *  单表查询，对该类对应的table进行查询
 *
 *  @param db          数据库
 *  @param keys        如果为nil代表 select *
 *  @param where       where语句
 *  @param others      limit 1 order by
 *  @param argumentAry 对应where语句里面的?参数，可以为nil
 *
 *  @return FMResultSet 使用next的话，必须调用close
 */
+ (FMResultSet*)query:(FMDatabase*)db queryKey:(NSArray*)keys where:(NSString*)where others:(NSString*)others argumentAry:(NSArray*)argumentAry;
+ (NSArray*)queryAndParse:(FMDatabase*)db queryKey:(NSArray*)keys where:(NSString*)where others:(NSString*)others argumentAry:(NSArray*)argumentAry;
/**
 *  多表查询，使用该方法会重命名列名，所以需要使用modelWithMultiResult来生成Model。
 *  select a.userId as TableName_userId from TableName a where
 *
 *  @param db             数据库
 *  @param tableKeys      二级数组，对应relationTables，如果不获取某张表的数据，设置成NSNull @[ [NSNull null], @[ @"key1", @"key2" ] ]
 *  @param relationTables Class 数量需要与tableKeys一致，relationTable[0]--> tableName as a, relationTable[1]--> tableName as b; [KKChatVersion class]
 *  @param where          a.ownerId = b.ownerId
 *  @param others         limit 1 order by
 *  @param argumentAry    对应where语句里面的?参数
 *
 *  @return FMResultSet 使用next的话，必须调用close
 */
+ (FMResultSet*)query:(FMDatabase*)db queryKey:(NSArray *)tableKeys relationTables:(NSArray*)relationTables where:(NSString *)where others:(NSString *)others argumentAry:(NSArray *)argumentAry;

/**
 *  数据库的插入操作
 *
 *  @param db
 *  @param keys 如果为空，那么上传全部数据, value为空的字段不上传，可以通过ignoreKeyWhenInsert屏蔽键值，例如主键字段
 *
 *  @return 返回插入的rowid，失败返回-1；
 */
- (int64_t)insert:(FMDatabase*)db insertKey:(NSArray*)keys;
- (int64_t)insertOrReplace:(FMDatabase*)db insertKey:(NSArray*)keys;
/**
 *  当插入数据的时候，参数keys为nil，那么可以通过这个函数来过滤不上传的键值 KKTableOptionalKey
 *
 *  @param keyName 键值
 *
 *  @return YES or NO
 */
- (BOOL)ignoreKeyWhenInsert:(NSString*)keyName;

/**
 *  更新数据库
 *
 *  @param db          数据库指针
 *  @param keys        需要更新的键值，必须填写
 *  @param where       where语句
 *  @param argumentAry where语句中传入的？对应的value
 *
 *  @return YES or NO
 */
- (BOOL)update:(FMDatabase*)db keys:(NSArray*)keys where:(NSString*)where argumentAry:(NSArray*)argumentAry;

+ (BOOL)deleteObject:(FMDatabase*)db where:(NSString*)where argumentAry:(NSArray*)argumentAry;

/**
 *  获取类的属性值
 *
 *  @return NSArray-->NSString
 */
+ (NSArray*)getAllDBKeys;
/**
 *  子类重写该方法，过滤掉非数据库字段
 *
 *  @return NSSet->NSString
 */
+ (NSSet*)notDBKeys;

+ (NSArray*)getAllProperty:(Class)classType;

@end
