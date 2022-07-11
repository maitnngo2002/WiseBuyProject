//
//  AlertManager.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "AlertManager.h"

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
@end
