//
//  SettingsViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "SettingsViewController.h"
#import "AlertManager.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (IBAction)didTapLogOut:(id)sender {
    [AlertManager logoutAlert:self];
}


@end
