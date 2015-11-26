//
//  PTToast.h
//  PubTools
//
//  Created by kyao on 15/11/25.
//  Copyright © 2015年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, kPTToastGravity) {
    kPTToastGravityCenter = 0,
    kPTToastGravityBottom
};

@interface PTToast : NSObject

+ (void)makeText:(NSString*)text;
+ (void)makeText:(NSString *)text gravity:(kPTToastGravity)gravity;

@end
