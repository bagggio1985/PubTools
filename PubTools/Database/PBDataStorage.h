//
//  KKChatStorage.h
//
//  Created by kyao on 15/7/27.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBDataModel.h"
#import "FMDB.h"

@interface PBDataStorage : NSObject

+ (instancetype)sharedStorage;

@property (nonatomic, strong) FMDatabaseQueue* dbQueue;

- (void)commonInit;

/**
 *  返回数据库需要创建的表的类
 *
 *  @return @[ [PBBaseModel class] ];
 */
- (NSArray*)registerTableArray;
/**
 *  初始化过程中，会调用该方法，提供修改的机会.
 *  如果子类需要更改数据库表结构等，重写该方法，不要调用super
 *
 *  @param orginal 原始数据库的版本号-- 0代表没有数据
 */
- (void)nowDbVersion:(NSInteger)orginal;
/**
 *  通过该方法设置当前数据库的版本号
 *
 *  @param version 版本号
 */
- (void)setDbVersion:(NSInteger)version;
/**
 *  使用FMResultSet生成对应的类实例数组
 *
 *  @param classType 类
 *  @param resultSet 数据库查询语句
 *
 *  @return 类实例数组
 */
- (NSArray*)instanceArrayByResult:(Class)classType result:(FMResultSet*)resultSet;

@end
