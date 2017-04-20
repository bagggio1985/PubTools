//
//  PTRoutes.m
//  KKTV
//
//  Created by kyao on 2017/4/20.
//
//

#import "PTRoutes.h"
#import "PTRouteInfo.h"
#import "pthread.h"

@interface PTRoutes () {
    OSSpinLock          _lock;
}

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableArray<PTRouteInfo*>*>* mapsOfRoute;

@end

@implementation PTRoutes

+ (instancetype)sharedRoutes {
    
    static PTRoutes* s_routes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_routes = [PTRoutes new];
    });
    
    return s_routes;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.mapsOfRoute = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)openUrl:(NSURL*)route withParams:(NSDictionary*)params {
    
    if (route == nil) return ;
    
    NSString* query = route.query;
    if ([query length]) {
        NSMutableDictionary* queryParam = [[NSMutableDictionary alloc] initWithDictionary:[query parseURLParams]];
        if ([params count]) {
            [queryParam addEntriesFromDictionary:params];
        }
        params = queryParam;
    }
    
    [self lock];
    
    NSMutableArray<PTRouteInfo*>* arys = [_mapsOfRoute objectForKey:[PTRouteInfo getRoutePath:route]];
    
    for (NSUInteger index = arys.count; index > 0; index--) {
        PTRouteInfo* routeInfo = arys[index-1];
        id target = routeInfo.weakTarget;
        if (target && routeInfo.handlerBlock) {
            
            if (routeInfo.queue == nil || (routeInfo.queue == dispatch_get_main_queue() && [NSThread isMainThread])) {
                if (routeInfo.handlerBlock(params)) {
                    [arys removeObjectAtIndex:index];
                }
            }
            else{
                
                WS(weakSelf);
                dispatch_async(routeInfo.queue, ^{
                    PTRoutes* strongSelf = weakSelf;
                    if (strongSelf) {
                        [strongSelf lock];
                        if (routeInfo.weakTarget && routeInfo.handlerBlock && routeInfo.handlerBlock(params)) {
                            [arys removeObject:routeInfo];
                        }
                        [strongSelf unlock];
                    }
                });
            }
        }
        else {
            [arys removeObjectAtIndex:index-1];
        }
    }
    
    [self unlock];
}

- (void)addRoute:(NSURL*)route target:(id)target handlerQueue:(dispatch_queue_t)queue handler:(BOOL (^)(NSDictionary *parameters))handler {
    if ([route.scheme length] == 0 || target == nil || handler == nil) return ;
    
    PTRouteInfo* routeInfo = [[PTRouteInfo alloc] initWithRoute:route handler:handler];
    routeInfo.queue = queue;
    routeInfo.weakTarget = target;
    [self _insertRouteInfo:routeInfo];
}

- (void)addRoute:(NSURL*)route target:(id)target handler:(BOOL (^)(NSDictionary *parameters))handler {
    [self addRoute:route target:target handlerQueue:nil handler:handler];
}

- (void)removeRoute:(NSURL*)route {
    
    [self lock];
    [_mapsOfRoute removeObjectForKey:[PTRouteInfo getRoutePath:route]];
    [self unlock];
}

- (void)removeAllRoutes {
    [self lock];
    [_mapsOfRoute removeAllObjects];
    [self unlock];
}

#pragma mark - Private

- (void)_insertRouteInfo:(PTRouteInfo*)info {
    [self lock];
    
    NSMutableArray<PTRouteInfo*>* arys = [_mapsOfRoute objectForKey:info.path];
    if (arys == nil) {
        arys = [[NSMutableArray alloc] initWithObjects:info, nil];
        [_mapsOfRoute setObject:arys forKey:info.path];
    }
    else {
        [arys addObject:info];
    }
    [self unlock];
}

- (void)lock {
    OSSpinLockLock(&_lock);
}

- (void)unlock {
    OSSpinLockUnlock(&_lock);
}

@end
