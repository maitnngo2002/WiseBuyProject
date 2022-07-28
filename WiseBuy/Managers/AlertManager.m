//
//  AlertManager.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "AlertManager.h"
#import "DatabaseManager.h"

@implementation AlertManager

+ (void)loginAlert:(errorType)error errorString:(nullable NSString *) errorString viewController:(UIViewController *)vc {
    UIAlertController *alert;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
    }];
    switch (error) {
        case LoginErrorMissingInput:
            alert = [UIAlertController alertControllerWithTitle:@"Missing Fields"
                                                        message:@"Username or/and password field is empty, try again."
                                                 preferredStyle:(UIAlertControllerStyleAlert)];
            [alert addAction:cancelAction];
            break;
        case ServerError:
            alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                        message:errorString
                                                 preferredStyle:(UIAlertControllerStyleAlert)];
            [alert addAction:okAction];
            break;
        case InputValidationError:
            alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                    message:@"Check if the fields contain any spaces"
                                             preferredStyle:(UIAlertControllerStyleAlert)];
            [alert addAction:okAction];
            break;
    }
    [vc presentViewController:alert animated:YES completion:^{}];
}

+ (void)logoutAlert:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout"
                                                                   message:@"Are you sure you want to log out of your account?"
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Logout"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [DatabaseManager logoutUser:vc];
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [vc presentViewController:alert animated:YES completion:nil];
}
+ (void)videoPermissionAlert:(UIViewController *)vc {
    UIAlertController *alert =  [UIAlertController alertControllerWithTitle:@"Unable to Continue"
                                                                    message:@"Enable camera access to continue."
                                                             preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *openSettingsAction = [UIAlertAction actionWithTitle:@"Open Settings"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
            [UIApplication.sharedApplication openURL:settingsURL options:[NSDictionary dictionary] completionHandler:^(BOOL success) {}];
        }
    }];
    
    [alert addAction:openSettingsAction];
    [vc presentViewController:alert animated:YES completion:^{
    }];
}

+ (void)dealsNotFoundAlert:(UIViewController *)vc errorType:(dealErrorType)error {
    UIAlertController *alert;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [vc.navigationController popToRootViewControllerAnimated:YES];
    }];
    
  
    alert = [UIAlertController alertControllerWithTitle:@"No Deals Found"
                                                        message:@"Could not find any deals for this item."
                                                 preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:okAction];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)cannotOpenLink:(UIViewController *)vc {
    UIAlertController *alert;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [vc.navigationController popToRootViewControllerAnimated:YES];
    }];
    alert = [UIAlertController alertControllerWithTitle:@"Error redirecting to the seller website"
                                                message:@"An error ocurred when redirecting to the link."
                                         preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:okAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)cannotSaveDeal:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error saving the deal"
                                                                   message:@"An occur occurred. Please try again."
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    [alert addAction:cancelAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)cannotPostDeal:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error posting the deal"
                                                                   message:@"An occur occurred. Please try again."
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    [alert addAction:cancelAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

@end
