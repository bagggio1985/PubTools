//
//  PlaceholderTextView.h
//  KKTV
//
//  Created by kyao on 16/6/7.
//
//

#import <UIKit/UIKit.h>

@interface PlaceholderTextView : UITextView

- (void)setPlaceholderTextColor:(UIColor*)textColor;
- (void)setPlaceholderText:(NSString*)text;
- (void)setPlaceholderTextFont:(UIFont*)textFont;

- (CGFloat)getLineHeight;

@end

@class TextLimitTextView;

// 返回处理过后的文字，如果不需要处理，直接返回toBeString
typedef NSString*(^TextLimitViewBlock)(NSString* toBeString);

@interface TextLimitTextView : PlaceholderTextView

@property (nonatomic, assign) int limitLength;

- (void)addTextLimitBlock:(TextLimitViewBlock)limitBlock;

@end
