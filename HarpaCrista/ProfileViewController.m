//
//  ProfileViewController.m
//  HarpaCrista
//
//  Created by Nguyen Bao on 10/10/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)revealMenu:(id)sender {
    ECSlidingViewController *slidingViewController = self.slidingViewController;
    if (slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [slidingViewController resetTopViewAnimated:YES];
    } else {
        [slidingViewController anchorTopViewToRightAnimated:YES];
    }
}

@end
