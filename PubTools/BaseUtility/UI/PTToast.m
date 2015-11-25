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
    [self makeText:text superView:[UIApplication sharedApplication].keyWindow yOffset:0];
}

+ (void)makeText:(NSString *)text superView:(UIView*)superView yOffset:(CGFloat)yOffset {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.yOffset = yOffset;
    hud.margin = 5.f;
    [hud hide:YES afterDelay:1.5];
}

@end
