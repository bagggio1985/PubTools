//
//  UIColor+Helper.h
//  PubTools
//
//  Created by kyao on 15/12/23.
//

#import <Foundation/Foundation.h>

@interface UIColor (Helper)

// 0xcccccc
+ (instancetype)colorWithRGB:(NSInteger)value;
+ (instancetype)colorWithRGB:(NSInteger)value alpha:(CGFloat)alpha;
// 0xcc
+ (instancetype)colorWithGray:(NSInteger)value;
+ (instancetype)colorWithGray:(NSInteger)value alpha:(CGFloat)alpha;

@end
