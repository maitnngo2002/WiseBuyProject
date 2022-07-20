//
//  ProgressHUDManager.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/19/22.
//

#import "ProgressHUDManager.h"

@implementation ProgressHUDManager

+ (void)setLoadingState:(BOOL)isLoading viewController:(UIViewController *)vc {
    if (isLoading) {
        vc.view.userInteractionEnabled = NO;
        vc.view.alpha = 0.3f;
        [vc.navigationController setNavigationBarHidden:YES];
        [vc.tabBarController.tabBar setHidden:YES];
    }
    else {
        vc.view.userInteractionEnabled = YES;
        [vc.navigationController setNavigationBarHidden:NO];
        [vc.tabBarController.tabBar setHidden:NO];
        vc.view.alpha = 1;
    }
}

@end
