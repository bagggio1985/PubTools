//
//  PTTextView.m
//  PubTools
//
//  Created by kyao on 15/12/23.
//

#import "PTTextView.h"

// Manually-selected label offsets to align placeholder label with text entry.
static CGFloat const kLabelLeftOffset = 7.f;
static CGFloat const kLabelTopOffset = 0.f;
//
//// When instantiated from IB, the text view has an 8 point top offset:
static CGFloat const kLabelTopOffsetFromIB = 8.f;
// On retina iPhones and iPads, the label is offset by 0.5 points:
static CGFloat const kLabelTopOffsetRetina = 0.5f;

@interface PTTextView ()

@property (nonatomic, strong) UILabel* placeholderLabel;
@property (nonatomic, assign) CGFloat topLabelOffset;

@end

@implementation PTTextView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _topLabelOffset = kLabelTopOffsetFromIB;
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _topLabelOffset = kLabelTopOffset;
        [self commonInit];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = [placeholder copy];
    self.placeholderLabel.text = placeholder;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = placeholderColor;
}

#pragma mark - OverWrite

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.placeholderLabel.font = self.font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    self.placeholderLabel.textAlignment = textAlignment;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self updatePlaceholderState];
}

- (id)insertDictationResultPlaceholder {
    id placeholder = [super insertDictationResultPlaceholder];
    self.placeholderLabel.hidden = YES;
    return placeholder;
}

// Update visibility when dictation ends.
- (void)removeDictationResultPlaceholder:(id)placeholder willInsertResult:(BOOL)willInsertResult {
    [super removeDictationResultPlaceholder:placeholder willInsertResult:willInsertResult];
    self.placeholderLabel.hidden = NO;
    [self updatePlaceholderState];
}

#pragma mark - Private
- (void)updatePlaceholderState {
    self.placeholderLabel.alpha = [self.text length] > 0 ? 0.f : 1.f;
}

- (void)commonInit {
    self.placeholderColor = [UIColor colorWithWhite:0.71f alpha:1.0f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    CGFloat labelLeftOffset = kLabelLeftOffset;
    CGFloat labelTopOffset = self.topLabelOffset;
        if ([[UIScreen mainScreen] scale] >= 2.0) {
        labelTopOffset += kLabelTopOffsetRetina;
    }
    
    self.placeholderLabel = [UILabel new];
    self.placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.text = self.placeholder;
    self.placeholderLabel.textColor = self.placeholderColor;
    [self addSubview:self.placeholderLabel];
    [self setupConstraints:CGPointMake(labelLeftOffset, labelTopOffset)];
    
    NSArray* log = self.constraints;
    DEBUG_NSLog(@"%@", log);
    
}

- (void)setupConstraints:(CGPoint)offset {
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.placeholderLabel
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeTop
                         multiplier:1
                         constant:offset.y]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.placeholderLabel
                         attribute:NSLayoutAttributeLeft
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeLeft
                         multiplier:1
                         constant:offset.x]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.placeholderLabel
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeWidth
                         multiplier:1
                         constant:-offset.x*2]];
}

- (void)textChanged:(NSNotification*)notification {
    [self updatePlaceholderState];
}


@end
