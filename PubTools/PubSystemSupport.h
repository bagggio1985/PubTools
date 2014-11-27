//
//  PubSystemSupport.h
//  PubTools
//
//  Created by kyao on 14-11-27.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

void async_main(dispatch_block_t block);
void async_global(dispatch_block_t block);

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


@end
