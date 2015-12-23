//
//  PTTextField.h
//
//  Created by kyao on 15/12/16.
//  Copyright © 2015年 kyao. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  设置leftView和rightView的时候会默认模式为UITextFieldViewModeAlways
 */
@interface PTTextField : UITextField

/**
 *  设置字体的左右和上下间距
 */
@property (nonatomic, assign) CGPoint insetsXY;

@end
