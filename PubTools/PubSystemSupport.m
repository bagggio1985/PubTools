//
//  PubSystemSupport.m
//  PubTools
//
//  Created by kyao on 14-11-27.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import "PubSystemSupport.h"
#import <objc/runtime.h>

@implementation PubSystemSupport

+ (NSString*)appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString*)appShortVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (CGSize)getPortraitSize {
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        return [UIScreen mainScreen].bounds.size;
    }
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
}

+ (CGSize)getLandscapeSize {
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        return [UIScreen mainScreen].bounds.size;
    }
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
}

+ (kIPhoneType)getPhoneType {
    
    static kIPhoneType s_iphoneType = kIPhoneType35Inch;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 处理屏幕的大小
        CGSize size = [self getPortraitSize];
        if (size.width == 320.f) {
            if (size.height == 480.f) {
                s_iphoneType = kIPhoneType35Inch;
            }
            else if (size.height == 568.f) {
                s_iphoneType = kIPhoneType4Inch;
            }
        }
        else if (size.width == 414.f) {
            s_iphoneType = kIPhoneType55Inch;
        }
        else if (size.width == 375.f) {
            s_iphoneType = kIPhoneType47Inch;
        }
    });
    
    return s_iphoneType;
}

+ (CGRect)getCenterRect:(CGSize)size parentRect:(CGSize)parentSize {
    CGRect ret = CGRectZero;
    ret.size.height = size.height;
    ret.size.width = size.width;
    
    ret.origin.x = (parentSize.width - size.width) / 2;
    ret.origin.y = (parentSize.height - size.height) / 2;
    
    return ret;
}

+ (id)viewWithNib:(NSString*)viewName owner:(id)owner {
    return [[[NSBundle mainBundle] loadNibNamed:viewName owner:owner options:nil] objectAtIndex:0];
}

+ (id)viewControllerWithNib:(NSString*)controllerName {
    if ([controllerName length] == 0) return nil;
    
    Class realClass = NSClassFromString(controllerName);
    if (realClass == nil) return nil;
    
    if (!class_respondsToSelector(realClass, @selector(initWithNibName:bundle:))) return nil;
    
    return  [[realClass alloc] initWithNibName:controllerName bundle:nil];
}

@end
