//
//  BaseViewController.h
//  PubTools
//
//  Created by kyao on 15-2-11.
//  Copyright (c) 2015年 . All rights reserved.
//

#import <UIKit/UIKit.h>



@interface BaseViewController : UIViewController

/// 实现该方法来初始化UI
/// 不要在viewDidLoad里面初始化UI
- (void)commonInit;

// 兼容ios6和7的状态条的显示方式
@property (nonatomic, assign) BOOL statusBarHidden;
- (void)setStatusBarHidden:(BOOL)statusBarHidden animated:(BOOL)animated;
@property (nonatomic, assign) BOOL navigationBarHidden;
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;

@property (nonatomic, assign) BOOL backWithAnimation; // default is YES
- (void)backAction:(id)sender;
- (void)backTo:(Class)view;

@end
