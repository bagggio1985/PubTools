//
//  PTTextField.m
//
//  Created by kyao on 15/12/16.
//  Copyright © 2015年 kyao. All rights reserved.
//

#import "PTTextField.h"

@implementation PTTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.insetsXY.x, self.insetsXY.y);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.insetsXY.x, self.insetsXY.y);
}

@end
