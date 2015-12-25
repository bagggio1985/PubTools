//
//  PTTextField.m
//
//  Created by kyao on 15/12/16.
//  Copyright © 2015年 kyao. All rights reserved.
//

#import "PTTextField.h"

@implementation PTTextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.insetsXY.x, self.insetsXY.y);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.insetsXY.x, self.insetsXY.y);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.insetsXY.x, self.insetsXY.y);
}

- (void)setRightView:(UIView *)rightView {
    [super setRightView:rightView];
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (void)setLeftView:(UIView *)leftView {
    [super setLeftView:leftView];
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)textFieldChange:(NSNotification*)notification {
    if (self.textLimit == 0) return ;
    
    NSString *toBeString = self.text;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    NSString* lang = [self.textInputMode primaryLanguage];
#else
    NSString* lang = [[UITextInputMode currentInputMode] primaryLanguage];
#endif
    
    NSUInteger limit = self.textLimit;
    if([lang isEqualToString:@"zh-Hans"]){ //简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [self markedTextRange];
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        if (!position){//非高亮
            if (toBeString.length > limit) {
                self.text = [toBeString substringToIndex:limit];
            }
        }
    }else{//中文输入法以外
        if (toBeString.length > limit) {
            self.text = [toBeString substringToIndex:limit];
        }
    }
}

@end
