//
//  BaseViewController.m
//  PubTools
//
//  Created by kyao on 15-2-11.
//  Copyright (c) 2015年 arcsoft. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, assign) BOOL isCommonInitEnd;
@property (nonatomic, assign) BOOL isVCBasedStatusBarAppearance;

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.backWithAnimation = YES;
        self.isCommonInitEnd = NO;
        
        self.statusBarHidden = NO;
        self.navigationBarHidden = NO;
        
        [self configVCBaseState];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isCommonInitEnd = NO;
    [self preCommonInit];
    [self commonInit];
    self.isCommonInitEnd = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置每一个view controller的导航条和状态条
    [self.navigationController setNavigationBarHidden:self.navigationBarHidden animated:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden withAnimation:animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
    [self animateStatusBar:animated];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    [self setStatusBarHidden:statusBarHidden animated:NO];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden animated:(BOOL)animated {
    if (_statusBarHidden == statusBarHidden) return ;
    _statusBarHidden = statusBarHidden;
    
    if (self.isCommonInitEnd) return ;
    
    [self animateStatusBar:animated];
    [self resetViewFrame];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated {
    if (_navigationBarHidden == navigationBarHidden) return ;
    _navigationBarHidden = navigationBarHidden;
    
    if (self.isCommonInitEnd) return ;
    [self.navigationController setNavigationBarHidden:self.navigationBarHidden animated:animated];
    [self resetViewFrame];
}

- (void)resetViewFrame {
    
    BOOL showStatus = !self.statusBarHidden;
    BOOL showNaviBar = !self.navigationBarHidden;
    
    CGSize size = [PubSystemSupport getPortraitSize];
    CGRect frame = CGRectZero;
    CGFloat y = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        y += (showStatus && showNaviBar ? 20.f : 0.f);
        y += (showNaviBar ? 44.f : 0.f);
        frame = CGRectMake(0, y, size.width, size.height-y);
    }
    else {
        y += (showNaviBar ? 44.f : 0.f);
        frame = CGRectMake(0, y, size.width, size.height-(showStatus?20.f:0)-y);
    }
    self.view.frame = frame;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Private

- (void)preCommonInit {
    [self resetViewFrame];
}

- (void)animateStatusBar:(BOOL)animated {
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        CGFloat animationDuration = (animated ? 0.35 : 0);
        if (!self.isVCBasedStatusBarAppearance) {
            // Non-view controller based
            [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden withAnimation:animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
        } else {
            // View controller based so animate away
            [UIView animateWithDuration:animationDuration animations:^(void) {
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:nil];
        }
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden withAnimation:animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
    }
    
}

- (void)configVCBaseState {
    
    static BOOL s_vcBased = NO;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSNumber *isVCBasedStatusBarAppearanceNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
        if (isVCBasedStatusBarAppearanceNum) {
            s_vcBased = isVCBasedStatusBarAppearanceNum.boolValue;
        } else {
            s_vcBased = YES; // default
        }
    });
    
    self.isVCBasedStatusBarAppearance = s_vcBased;
}

#pragma mark PublicMethod

- (void)commonInit {
    
}

-(void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:self.backWithAnimation];
}

- (void)backTo:(Class)view {
    for (id key in self.navigationController.viewControllers) {
        if ([key isKindOfClass:view]){
            [self.navigationController popViewControllerAnimated:self.backWithAnimation];
            break;
        }
    }
}

@end
