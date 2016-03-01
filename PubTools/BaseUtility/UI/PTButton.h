//
//  PTButton.h
//
//  Created by kyao on 16/3/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PTImagePosition) {
    PTImagePositionNone = 0,
    PTImagePositionLeft,              //图片在左，文字在右，默认
    PTImagePositionRight,             //图片在右，文字在左
    PTImagePositionTop,               //图片在上，文字在下
    PTImagePositionBottom,            //图片在下，文字在上
};

@interface PTButton : UIButton

- (void)setImagePosition:(PTImagePosition)postion spacing:(CGFloat)spacing;

@end
