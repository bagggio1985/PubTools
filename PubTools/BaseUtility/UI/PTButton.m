//
//  PTButton.m
//
//  Created by kyao on 16/3/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "PTButton.h"

@interface PTButton ()

@property (nonatomic, assign) PTImagePosition position;
@property (nonatomic, assign) CGFloat spacing;

@end

@implementation PTButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.position != PTImagePositionNone) {
        [self setupImagePosition];
    }
}

- (void)setupImagePosition {
    CGFloat imageWith = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;

    CGFloat labelWidth = [self.titleLabel.text estimateSizeWithFont:self.titleLabel.font].width;
    CGFloat labelHeight = [self.titleLabel.text estimateSizeWithFont:self.titleLabel.font].height;
    
    CGFloat imageOffsetX = (imageWith + labelWidth) / 2 - imageWith / 2;//image中心移动的x距离
    CGFloat imageOffsetY = imageHeight / 2 + self.spacing / 2;//image中心移动的y距离
    CGFloat labelOffsetX = (imageWith + labelWidth / 2) - (imageWith + labelWidth) / 2;//label中心移动的x距离
    CGFloat labelOffsetY = labelHeight / 2 + self.spacing / 2;//label中心移动的y距离
    
    CGFloat totolHeight = imageHeight + labelHeight + self.spacing;
    CGFloat margin = (CGRectGetHeight(self.frame) - totolHeight) / 2;
    
    CGFloat spacing = self.spacing;
    switch (self.position) {
        case PTImagePositionLeft:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2, 0, spacing/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, -spacing/2);
            break;
            
        case PTImagePositionRight:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + spacing/2, 0, -(labelWidth + spacing/2));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageHeight + spacing/2), 0, imageHeight + spacing/2);
            break;
            
        case PTImagePositionTop:
        {
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY + margin, imageOffsetX, imageOffsetY - margin, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY + margin, -labelOffsetX, -labelOffsetY - margin, labelOffsetX);
        }
            break;
            
        case PTImagePositionBottom:
        {
            self.imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY - margin, imageOffsetX, -imageOffsetY + margin, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY - margin, -labelOffsetX, labelOffsetY + margin, labelOffsetX);
        }
            break;
            
        default:
            break;
    }
}

- (void)setImagePosition:(PTImagePosition)postion spacing:(CGFloat)spacing; {
    self.position = postion;
    self.spacing = spacing;
}

@end
