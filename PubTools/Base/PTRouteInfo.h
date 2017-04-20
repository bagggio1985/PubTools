//
//  PTRouteInfo.h
//  KKTV
//
//  Created by kyao on 2017/4/20.
//
//

#import <Foundation/Foundation.h>

typedef BOOL(^PTRouteHanlderBlock)(NSDictionary* param);

@interface PTRouteInfo : NSObject

@property (nonatomic, strong, readonly) NSString* path;
@property (nonatomic, copy, readonly) PTRouteHanlderBlock handlerBlock;

@property (atomic, weak) dispatch_queue_t queue;
@property (atomic, weak) id weakTarget;

- (instancetype)initWithRoute:(NSURL*)route handler:(PTRouteHanlderBlock)handler;

+ (NSString*)getRoutePath:(NSURL*)url;

@end
