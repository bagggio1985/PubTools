//
//  PTTextView.h
//  PubTools
//
//  Created by kyao on 15/12/23.
//  Copyright © 2015年 arcsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTTextView : UITextView

@property (nonatomic, copy) NSString* placeholder;
@property (nonatomic, strong) UIColor* placeholderColor;

@property (nonatomic, assign) NSUInteger textLimit;

@end
