//
//  PTRouteInfo.m
//  KKTV
//
//  Created by kyao on 2017/4/20.
//
//

#import "PTRouteInfo.h"


@interface PTRouteInfo ()

@property (nonatomic, copy) PTRouteHanlderBlock handlerBlock;
@property (nonatomic, strong) NSString* path;

@end

@implementation PTRouteInfo

- (instancetype)initWithRoute:(NSURL*)route handler:(PTRouteHanlderBlock)handler {
    
    if (self = [super init]) {
        self.path = [[self class] getRoutePath:route];
        self.handlerBlock = handler;
    }
    
    return self;
}

+ (NSString*)getRoutePath:(NSURL*)route {
    return [NSString stringWithFormat:@"%@://%@/%@", route.scheme, route.host?:@"", route.path?:@""];
}

@end
