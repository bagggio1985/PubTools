//
//  PTRoutes.h
//  KKTV
//
//  Created by kyao on 2017/4/20.
//
//

#import <Foundation/Foundation.h>

@interface PTRoutes : NSObject

+ (instancetype)sharedRoutes;

/**
 通知事件的发生

 @param route 事件字段 kkvr://home?a=b&b=c
 @param params 参数
 */
- (void)openUrl:(NSURL*)route withParams:(NSDictionary*)params;

/**
 添加事件的响应函数

 @param route 事件字段--> kkvr://home
 @param target block的所属对象，用来判断调用block时target是否已经释放
 @param handler 返回BOOL代表是否删除该响应函数
 */
- (void)addRoute:(NSURL*)route target:(id)target handler:(BOOL (^)(NSDictionary *parameters))handler;

- (void)addRoute:(NSURL*)route target:(id)target handlerQueue:(dispatch_queue_t)queue handler:(BOOL (^)(NSDictionary *parameters))handler;

- (void)removeRoute:(NSURL*)route;

- (void)removeAllRoutes;

@end
