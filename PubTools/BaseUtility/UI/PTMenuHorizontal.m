//
//  PTMenuHorizontal.m
//
//
//

#import "PTMenuHorizontal.h"
#import "Masonry.h"

@interface PTMenuHorizontal ()

@property (nonatomic, strong) NSArray* menuTitleArray;

@property (nonatomic, strong) NSMutableArray* buttonArray;
@property (nonatomic, strong) UIView* highlightView;
@property (nonatomic, weak) UIScrollView* scrollView;
@property (nonatomic, weak) UIButton* selectedButton;

@end

@implementation PTMenuHorizontal

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    for (UIButton* button in self.buttonArray) {
        [button setTitleColor:highlightColor forState:UIControlStateSelected];
    }
    self.highlightView.backgroundColor = highlightColor;
}

- (void)setTitleArray:(NSArray<NSString*> *)titles {
    [self resetMenu];
    self.menuTitleArray = titles;
    [self createButtons:titles];
}

- (void)moveToIndex:(NSInteger)index {
    if (index >= self.buttonArray.count) return ;
    
    UIButton* button = [self.buttonArray objectAtIndex:index];
    [self changeSelectedButton:button];
    [self centerButton:button];
}

- (NSInteger)getSelectedIndex {
    return _selectedButton ? _selectedButton.tag : -1;
}

#pragma mark - Private

- (void)commonInit {
    self.highlightColor = [UIColor colorWithRed:17.f/255.f green:210.f/255.f blue:162.f/255.f alpha:1];
    self.backgroundColor = [UIColor whiteColor];
    self.buttonArray = [NSMutableArray new];
}

- (void)resetMenu {
    // 清空数据
    self.selectedButton = nil;
    [self.buttonArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.buttonArray removeAllObjects];
    [self.scrollView removeFromSuperview];
    [self.highlightView removeFromSuperview];
    
    UIScrollView* scrollView = [UIScrollView new];
    scrollView.backgroundColor = self.backgroundColor;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self);
        make.left.top.mas_equalTo(0);
    }];
    
    UIView* highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, scrollView.frame.size.height-2, 0, 2)];
    highlightView.backgroundColor = self.highlightColor;
    [scrollView addSubview:highlightView];
    self.highlightView = highlightView;
    [highlightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(scrollView);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
}

- (void)createButtons:(NSArray*)titles {
    CGFloat padding = 15.f;
    UIView* lastView = nil;
    for (int index = 0; index < titles.count; index++) {
        NSString* title = [titles objectAtIndex:index];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:15.f];
        button.tag = index;
        [button setTitleColor:RGBFromHexadecimal(0x818181) forState:UIControlStateNormal];
        [button setTitleColor:self.highlightColor forState:UIControlStateSelected];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(menuClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonArray addObject:button];
        [self.scrollView addSubview:button];
        
        CGFloat width = [title sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}].width + padding*2;
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo( lastView ? lastView.mas_right : self.scrollView.mas_left );
            make.top.mas_equalTo(0);
            make.height.equalTo(self.scrollView);
            make.width.mas_equalTo(width);
            if (index + 1 == titles.count) {
                make.right.equalTo(self.scrollView.mas_right).priorityLow();
            }
        }];
        lastView = button;
    }
    
    self.highlightView.hidden = (self.buttonArray.count == 0);
    if (self.buttonArray.count > 0) {
        [self menuClicked:self.buttonArray[0]];
    }
}

- (void)resetHighlightView:(UIButton*)button {
    self.selectedButton.selected = NO;
    self.selectedButton = button;
    button.selected = YES;
    [self.highlightView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(button.mas_bottom);
        make.width.mas_equalTo(button.titleLabel);
        make.height.mas_equalTo(2);
        make.centerX.equalTo(button);
    }];
}

- (void)menuClicked:(UIButton*)sender {
    [self changeSelectedButton:sender];
    if ([self.delegate respondsToSelector:@selector(onMenuClickedAtIndex:)]) {
        [self.delegate onMenuClickedAtIndex:sender.tag];
    }
}

- (void)changeSelectedButton:(UIButton*)sender {
    [self resetHighlightView:sender];
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView layoutIfNeeded];
    }];
}

- (void)centerButton:(UIButton*)button {
    if (self.scrollView.contentSize.width < self.frame.size.width) return ;
    int maxOffset = self.scrollView.contentSize.width - self.frame.size.width;
    int offset = button.center.x - self.frame.size.width/2;
    offset = MIN(MAX(0, offset), maxOffset);
    [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

@end
