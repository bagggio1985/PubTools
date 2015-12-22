//
//  PTBaseViewController.h
//  PubTools
//
//  Created by kyao on 15/11/25.
//  Copyright © 2015年 arcsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTBaseViewController : UIViewController

#pragma mark - Navigation Bar Fuction
- (void)setLeftBarBack;
- (void)setLeftBarText:(NSString*)back;
- (void)setLeftBarItem:(NSString*)text action:(SEL)selector;
- (void)setLeftBarItem:(SEL)selector image:(NSString*)normalImage highlightedImage:(NSString*)highlightedImage;
- (void)setRightBarItem:(NSString*)text action:(SEL)selector;
- (void)setRightBarItem:(SEL)selector image:(NSString*)normalImage image:(NSString*)highlightedImage;
- (void)dismissRightBarItem;
- (void)setRightBarItemEnable:(BOOL)enable;
- (void)backAction:(id)sender;
- (void)backTo:(Class)view animated:(BOOL)animated;

- (void)showLoadingView;
- (void)hideLoadingView;

- (void)showToast:(NSString*)toast;

#pragma mark - MaskOn
- (void)setMaskOn:(BOOL)on;
- (void)onMaskTaped;

@end
