//
//  PTBaseViewController.m
//  PubTools
//
//  Created by kyao on 15/11/25.
//  Copyright © 2015年 arcsoft. All rights reserved.
//

#import "PTBaseViewController.h"

@interface PTBaseViewController ()

@property (nonatomic, strong) UITapGestureRecognizer* tapReconizer;

@end

@implementation PTBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Navigation Bar Fuction
- (void)setLeftBarBack {
    [self setLeftBarItem:nil image:@"btn_back" highlightedImage:nil];
}

- (void)setLeftBarText:(NSString*)back {
    UIBarButtonItem * rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:back
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(backAction:)];
    rightBarBtn.tintColor = [UIColor whiteColor];
    [rightBarBtn setTitlePositionAdjustment:UIOffsetMake(4.0f, 0) forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = rightBarBtn;
}

- (void)setLeftBarItem:(NSString *)text action:(SEL)selector
{
    UIBarButtonItem * rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:text
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:selector];
    rightBarBtn.tintColor = [UIColor whiteColor];
    [rightBarBtn setTitlePositionAdjustment:UIOffsetMake(4.0f, 0) forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = rightBarBtn;
}

- (void)setLeftBarItem:(SEL)selector image:(NSString*)normalImage highlightedImage:(NSString*)highlightedImage {
    //设置leftBarButtonItem
    UIButton* leftBarBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 26, 26)];
    [leftBarBtn setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [leftBarBtn setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    [leftBarBtn addTarget:self action:selector ? : @selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0f, -5, 0, 5);
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = buttonItem;
}

- (void)setRightBarItem:(NSString*)text action:(SEL)selector
{
    UIBarButtonItem * rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:text
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:selector];
    rightBarBtn.tintColor = [UIColor whiteColor];
    [rightBarBtn setTitlePositionAdjustment:UIOffsetMake(-4.0f, 0) forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = rightBarBtn;
}

- (void)setRightBarItem:(SEL)selector image:(NSString*)normalImage image:(NSString*)highlightedImage
{
    //设置rightBarButtonItem
    UIButton* rightBarButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 26, 26)];
    if (normalImage) {
        [rightBarButton setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    }
    if (highlightedImage) {
        [rightBarButton setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    }
    if (selector) {
        [rightBarButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    rightBarButton.imageEdgeInsets = UIEdgeInsetsMake(0,5,0,-5);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
}

- (void)dismissRightBarItem {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)setRightBarItemEnable:(BOOL)enable {
    self.navigationItem.rightBarButtonItem.enabled = enable;
    UIButton* btn = (UIButton*)self.navigationItem.rightBarButtonItem.customView;
    btn.enabled = enable;
}

- (void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backTo:(Class)view animated:(BOOL)animated {
    for (id key in self.navigationController.viewControllers) {
        if ([key isKindOfClass:view]){
            [self.navigationController popToViewController:key animated:animated];
            break;
        }
    }
}

#pragma mark - MaskOn
- (void)setMaskOn:(BOOL)on {
    if (on) {
        if (nil == self.tapReconizer) {
            self.tapReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGestureAction:)];
            [self.view addGestureRecognizer:self.tapReconizer];
        }
    }
    else {
        [self clearTapGesture];
    }
}

- (void)clearTapGesture {
    [self.tapReconizer.view removeGestureRecognizer:self.tapReconizer];
    self.tapReconizer = nil;
}

- (void)onTapGestureAction:(UITapGestureRecognizer*)rec {
    [self clearTapGesture];
    [self onMaskTaped];
}

- (void)onMaskTaped {
    
}

@end
