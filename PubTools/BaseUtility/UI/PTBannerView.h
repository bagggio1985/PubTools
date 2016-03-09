//
//  PTBannerView.h
//
//  Created by kyao on 16/2/3.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PTBannerViewDelegate;

@interface PTBannerView : UIView

@property (nonatomic, weak) id<PTBannerViewDelegate> delegate;
@property (nonatomic, assign) BOOL autoScroll; // 定时滑动

@end

@protocol PTBannerViewDelegate <NSObject>

@optional
- (void)bannerView:(PTBannerView*)bannerView clickedIndex:(NSUInteger)index;

@required
- (NSUInteger)numbersOfBannerView:(PTBannerView*)bannerView;
- (void)bannerView:(PTBannerView*)bannerView imageView:(UIImageView*)imageView index:(NSUInteger)index;

@end

