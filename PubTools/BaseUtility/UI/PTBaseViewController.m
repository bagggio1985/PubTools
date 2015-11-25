//
//  PTBaseViewController.m
//  PubTools
//
//  Created by kyao on 15/11/25.
//  Copyright © 2015年 arcsoft. All rights reserved.
//

#import "PTBaseViewController.h"

@interface PTBaseViewController ()

@end

@implementation PTBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
