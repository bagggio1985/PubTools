//
//  UIImage+Helper.h
//  PubTools
//
//  Created by kyao on 14-9-1.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage*)fillInSize:(CGSize)size;
- (UIImage*)fitInSize:(CGSize)size;

- (UIImage*)imageRotatedByRadians:(CGFloat)radians;
- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;

@end
