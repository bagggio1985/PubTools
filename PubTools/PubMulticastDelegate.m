//
//  PubMulticastDelegate.m
//  BeautyPie
//
//  Created by kyao on 15-1-26.
//  Copyright (c) 2015年 arcsoft. All rights reserved.
//

#import "PubMulticastDelegate.h"

@interface PubMulticastDelegateNode : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) NSString* event;

- (id)initWithDelegate:(id)delegate selector:(SEL)selector event:(NSString*)event;

@end

@implementation PubMulticastDelegateNode

- (id)initWithDelegate:(id)delegate selector:(SEL)selector event:(NSString *)event {
    if (self = [super init]) {
        self.delegate = delegate;
        self.event = event;
        self.selector = selector;
    }
    
    return self;
}

@end

@interface PubMulticastDelegate ()

@property (nonatomic, strong) NSMutableArray* delegateNodes;

@end

@implementation PubMulticastDelegate

+ (instancetype)sharedMulticastDelegate {
    
    static PubMulticastDelegate* multicastDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        multicastDelegate = [[PubMulticastDelegate alloc] init];
    });
    return multicastDelegate;
    
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.delegateNodes = [NSMutableArray array];
}

- (void)addDelegate:(id)delegate selector:(SEL)selector relatedEvent:(NSString*)event {
    if (delegate == nil || [event length] == 0) return ;
    
    [self invokeSync:^{
        PubMulticastDelegateNode *node = [[PubMulticastDelegateNode alloc] initWithDelegate:delegate selector:selector event:event];
        [self.delegateNodes addObject:node];
    }];
}

- (void)removeDelegate:(id)delegate relatedEvent:(NSString*)event {
    if (delegate == nil) return ;
    
    [self invokeSync:^{
        for (int index = [self.delegateNodes count]; index > 0; index--) {
            PubMulticastDelegateNode* node = self.delegateNodes[index-1];
            
            // 无效的delegate或者相同的delegate需要释放掉
            if (node.delegate == nil || (delegate == node.delegate && (nil == event || [event isEqualToString:node.event]))) {
                [self.delegateNodes removeObjectAtIndex:index-1];
            }
        }
    }];
}

- (void)dispatchEvent:(NSString*)event {
    if ([event length] == 0) return ;
    
    [self invokeAsync:^{
        for (int index = [self.delegateNodes count]; index > 0;  index--) {
            PubMulticastDelegateNode* node = self.delegateNodes[index-1];
            
            if (node.delegate == nil) {
                [self.delegateNodes removeObjectAtIndex:index-1];
            }
            else {
                if ([node.delegate respondsToSelector:node.selector]) {
                    
                    NSMethodSignature *methodSig = [node.delegate methodSignatureForSelector:node.selector];
                    // 0 and 1 is self and _cmd
                    int num = [methodSig numberOfArguments];

                    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
                    [invocation setTarget:node.delegate];
                    [invocation setSelector:node.selector];
                    
                    switch (num) {
                        case 2:
                            [invocation invoke];
                            break;
                        case 3:
                        {
                            NSString* backEvent = event;
                            [invocation setArgument:&backEvent atIndex:2];
                            [invocation invoke];
                        }
                            break;
                        default:
                            break;
                    }
                    
                }
            }
        }
    }];
}

- (void)invokeAsync:(dispatch_block_t)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            block();
        }
    });
}

- (void)invokeSync:(dispatch_block_t)block {
    
    if ([NSThread isMainThread]) {
        block();
        return ;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            block();
        }
    });
}

@end
