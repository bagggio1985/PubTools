//
//  PubSystemSupport.h
//  PubTools
//
//  Created by kyao on 14-11-27.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kIPhoneType35Inch = 0,
    kIPhoneType4Inch = 1,
    kIPhoneType47Inch = 2,
    kIPhoneType55Inch = 3
} kIPhoneType;

@interface PubSystemSupport : NSObject

+ (NSString*)appVersion;
+ (NSString*)appShortVersion;

+ (CGSize)getPortraitSize;
+ (CGSize)getLandscapeSize;

+ (kIPhoneType)getPhoneType;

+ (CGRect)getCenterRect:(CGSize)size parentRect:(CGSize)parentSize;

+ (id)viewWithNib:(NSString*)viewName owner:(id)owner;
+ (id)viewControllerWithNib:(NSString*)controllerName;

@end
