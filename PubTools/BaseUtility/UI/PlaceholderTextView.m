//
//  PlaceholderTextView.m
//  KKTV
//
//  Created by kyao on 16/6/7.
//
//

#import "PlaceholderTextView.h"

@interface PlaceholderTextView () {
    __weak UILabel* _placeholderLabel;
    CGFloat _textMarginX;
    CGFloat _lastWidth;
}

@end

@implementation PlaceholderTextView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _textMarginX = self.textContainer.lineFragmentPadding + self.textContainerInset.left + self.contentInset.left;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.f];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    [self addSubview:label];
    _placeholderLabel = label;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPlaceholderTextColor:(UIColor *)textColor {
    _placeholderLabel.textColor = textColor;
}

- (void)setPlaceholderTextFont:(UIFont *)textFont {
    _placeholderLabel.font = textFont;
    [self updatePlaceholderText];
}

- (void)setPlaceholderText:(NSString *)text {
    _placeholderLabel.text = text;
    [self updatePlaceholderText];
}

- (void)updatePlaceholderText {
    CGSize size = [_placeholderLabel.text boundingRectWithSize:CGSizeMake([self getTextContainerWidth], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_placeholderLabel.font} context:nil].size;
    _placeholderLabel.frame = CGRectMake(_textMarginX, [self getTextContainerTop], size.width, size.height);
}

- (CGFloat)getTextContainerWidth {
    CGFloat width = self.frame.size.width - _textMarginX * 2;
    if (width < 0.f) return 0;
    
    return width;
}

- (CGFloat)getLineHeight {
    CGSize size = [@"我" boundingRectWithSize:CGSizeMake([self getTextContainerWidth], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_placeholderLabel.font} context:nil].size;
    
    return size.height + self.textContainerInset.top + self.textContainerInset.bottom;
}

- (CGFloat)getTextContainerTop {
    return self.textContainerInset.top + self.contentInset.top;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_lastWidth != self.contentSize.width) {
        _lastWidth = self.contentSize.width;
        [self updatePlaceholderText];
    }
}

#pragma mark - TextView Event
- (void)textDidChange:(NSNotification*)notification {
    if (notification.object != self) return ;
    _placeholderLabel.hidden = self.text.length > 0;
}

@end

@interface TextLimitTextView ()

@property (nonatomic, copy) TextLimitViewBlock limitBlock;

@end

@implementation TextLimitTextView

- (void)addTextLimitBlock:(TextLimitViewBlock)limitBlock {
    self.limitBlock = limitBlock;
}

- (void)textDidChange:(NSNotification*)notification {
    [super textDidChange:notification];
    if (notification.object != self) return ;
    if (self.limitLength <= 0) return ;
    
    UITextView *textField = self;
    NSString *toBeString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        
        if (self.limitBlock) {
            NSString* limitString = self.limitBlock(toBeString);
            textField.text = limitString;
        }
        else if (toBeString.length > _limitLength) {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:_limitLength];
            if (rangeIndex.length == 1) {
                textField.text = [toBeString substringToIndex:_limitLength];
            }
            else {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, _limitLength)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}

@end