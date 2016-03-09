//
//  PTBannerView.m
//
//  Created by kyao on 16/2/3.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "PTBannerView.h"

@interface PTBannerView () <UIScrollViewDelegate> {
    NSUInteger _curPageIndex;
    NSUInteger _totalCount;
}

@property (nonatomic, weak) UIScrollView* scrollView;
@property (nonatomic, strong) NSMutableArray* imageViewArray; // 固定三个

@end

@implementation PTBannerView

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

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resetViewFrame];
}

- (void)reloadData {
    _totalCount = [self.delegate numbersOfBannerView:self];
    [self clearImageView];
    [self refreshPage];
    [self resetViewFrame];
}

- (void)setDelegate:(id<PTBannerViewDelegate>)delegate {
    _delegate = delegate;
    [self reloadData];
}

- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    if (!_autoScroll) {
        [self stopAutoScroll];
    }
    else {
        [self startAutoScroll];
    }
}

#pragma mark - Private

- (void)commonInit {
    _curPageIndex = 0;
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    [self setupImageView];
    [self reloadData];
}

- (void)setupImageView {
    self.imageViewArray = [[NSMutableArray alloc] initWithCapacity:3];
    for (int index = 0; index < 3; index++) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:imageView];
        [self.imageViewArray addObject:imageView];
    }
}

- (void)clearImageView {
    for (UIImageView* imageView in self.imageViewArray) {
        if (_totalCount == 0) {
            imageView.image = nil;
        }
        imageView.hidden = (_totalCount == 0);
    }
}

- (void)refreshPage {
    for (NSInteger index = 0; index < 3; index++) {
        UIImageView* imageView = [self.imageViewArray objectAtIndex:index];
        switch (index) {
            case 0:
                [self.delegate bannerView:self imageView:imageView index:[self getPrePageIndex:_curPageIndex]];
                break;
            case 1:
                [self.delegate bannerView:self imageView:imageView index:_curPageIndex];
                break;
            case 2:
                [self.delegate bannerView:self imageView:imageView index:[self getNextPageIndex:_curPageIndex]];
                break;
            default:
                break;
        }
    }
}

- (void)movePage:(NSInteger)direction {
    if (direction > 0) {
        // 向右划
        _curPageIndex = [self getNextPageIndex:_curPageIndex];
        [self.imageViewArray exchangeObjectAtIndex:0 withObjectAtIndex:1];
        [self.imageViewArray exchangeObjectAtIndex:1 withObjectAtIndex:2];
        UIImageView* reloadView = self.imageViewArray[2];
        [self.delegate bannerView:self imageView:reloadView index:[self getNextPageIndex:_curPageIndex]];
    }
    else if (direction < 0) {
        // 向左滑
        _curPageIndex = [self getPrePageIndex:_curPageIndex];
        [self.imageViewArray exchangeObjectAtIndex:2 withObjectAtIndex:1];
        [self.imageViewArray exchangeObjectAtIndex:1 withObjectAtIndex:0];
        UIImageView* reloadView = self.imageViewArray[0];
        [self.delegate bannerView:self imageView:reloadView index:[self getPrePageIndex:_curPageIndex]];
    }
    [self resetViewFrame];
}

- (void)resetViewFrame {
    CGFloat width = self.scrollView.frame.size.width;
    NSUInteger count = self.imageViewArray.count;
    for (NSUInteger index = 0; index < count; index++) {
        UIImageView *imageView = [self.imageViewArray objectAtIndex:index];
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = index*width;
        imageView.frame = frame;
    }
    self.scrollView.contentSize = CGSizeMake(count*width, 0);
    [self.scrollView setContentOffset:CGPointMake(width, 0)];
}

- (NSInteger)getNextPageIndex:(NSInteger)page {
    if (page+1 >= _totalCount) return 0;
    return page+1;
}

- (NSInteger)getPrePageIndex:(NSInteger)page {
    if (page <= 0) return _totalCount-1;
    return page-1;
}

- (void)startAutoScroll {
    if (!_autoScroll) return ;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollBannerView) object:nil];
    [self performSelector:@selector(scrollBannerView) withObject:nil afterDelay:2];
}

- (void)stopAutoScroll {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollBannerView) object:nil];
}

- (void)scrollBannerView {
    _curPageIndex = [self getNextPageIndex:_curPageIndex];
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*2, 0) animated:YES];
}

- (void)dealloc {
    [self stopAutoScroll];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopAutoScroll];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self reloadData];
    [self startAutoScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self startAutoScroll];
    
    CGFloat x = scrollView.contentOffset.x;
    
    NSInteger index = (int)x / scrollView.bounds.size.width;
    if (index != 1) {
        [self movePage:index>1?1:-1];
    }
}

@end
