//
//  PTToast.m
//  PubTools
//
//  Created by kyao on 15/11/25.
//  Copyright © 2015年 arcsoft. All rights reserved.
//

#import "PTToast.h"
#import "MBProgressHUD.h"

@implementation PTToast

+ (void)makeText:(NSString*)text {
    [self makeText:text superView:[UIApplication sharedApplication].keyWindow yOffset:0 gravity:kPTToastGravityCenter];
}

+ (void)makeText:(NSString *)text gravity:(kPTToastGravity)gravity {
    [self makeText:text superView:[UIApplication sharedApplication].keyWindow yOffset:0 gravity:gravity];
}

+ (void)makeText:(NSString *)text superView:(UIView*)superView yOffset:(CGFloat)yOffset gravity:(kPTToastGravity)gravity {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 8.f;
    hud.cornerRadius = 5;
    
    switch (gravity) {
        case kPTToastGravityBottom:
        {
            hud.yOffset = CGRectGetHeight(superView.frame) / 2 - 50.f + yOffset;
        }
            break;
        case kPTToastGravityCenter:
        {
            hud.yOffset = yOffset;
        }
        default:
            break;
    }
    [hud hide:YES afterDelay:1.5];
}

@end
