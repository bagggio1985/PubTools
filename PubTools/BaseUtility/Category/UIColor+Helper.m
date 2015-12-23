//
//  UIColor+Helper.m
//  PubTools
//
//  Created by kyao on 15/12/23.
//

#import "UIColor+Helper.h"

@implementation UIColor (Helper)

+ (instancetype)colorWithRGB:(NSInteger)value {
    return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16))/255.0 green:((float)((value & 0xFF00) >> 8))/255.0 blue:((float)(value & 0xFF))/255.0 alpha:1.0];
}

+ (instancetype)colorWithRGB:(NSInteger)value alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16))/255.0 green:((float)((value & 0xFF00) >> 8))/255.0 blue:((float)(value & 0xFF))/255.0 alpha:1.0];
}

+ (instancetype)colorWithGray:(NSInteger)value {
    CGFloat color = (float)(value & 0xFF)/255.0;
    return [UIColor colorWithRed:color green:color blue:color alpha:1.0];
}

+ (instancetype)colorWithGray:(NSInteger)value alpha:(CGFloat)alpha {
    CGFloat color = (float)(value & 0xFF)/255.0;
    return [UIColor colorWithRed:color green:color blue:color alpha:alpha];
}

@end
