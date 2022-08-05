//
//  AlertManager.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "AlertManager.h"
#import "DatabaseManager.h"

static NSString *const kCancel = @"Cancel";
static NSString *const kOk = @"OK";
static NSString *const kMissingFields = @"Missing Fields";
static NSString *const kError = @"Error";
static NSString *const kLoginErrorMissingInputMessage = @"Username or/and password field is empty, try again.";
static NSString *const kInputValidationErrorMessage = @"Check if the fields contain any spaces";
static NSString *const kLogOut = @"Logout";
static NSString *const kLogOutMessage = @"Are you sure you want to log out of your account?";
static NSString *const kVideoPermissionAlertTitle = @"Unable to Continue";
static NSString *const kVideoPermissionAlertMessage = @"Enable camera access to continue.";
static NSString *const kOpenSettings = @"Open Settings";
static NSString *const kDealsNotFoundAlertTitle = @"No Deals Found";
static NSString *const kDealsNotFoundAlertMessage = @"Could not find any deals for this item.";
static NSString *const kCannotOpenLinkAlertTitle = @"Error redirecting to the seller website";
static NSString *const kCannotOpenLinkAlertMessage = @"An error ocurred when redirecting to the link.";
static NSString *const kCannotSaveDealAlertTitle = @"Error saving the deal";
static NSString *const kCannotSaveDealOrPostDealAlertMessage = @"An occur occurred. Please try again.";
static NSString *const kCannotPostDealAlertTitle = @"Error posting the deal";
static NSString *const kPostDealMissingFields = @"Missing fields. Please ensure you have filled in all the required fields";
static NSString *const kInvalidUrl = @"Invalid URL. Please enter a valid buy link";
static NSString *const kInvalidPriceInputAlert = @"Invalid price value. Please enter a valid price number";

@implementation AlertManager

+ (void)loginAlert:(errorType)error errorString:(nullable NSString *) errorString viewController:(UIViewController *)vc {
    UIAlertController *alert;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kCancel
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
    }];
    switch (error) {
        case LoginErrorMissingInput:
            alert = [UIAlertController alertControllerWithTitle:kMissingFields
                                                        message:kLoginErrorMissingInputMessage
                                                 preferredStyle:(UIAlertControllerStyleAlert)];
            [alert addAction:cancelAction];
            break;
        case ServerError:
            alert = [UIAlertController alertControllerWithTitle:kError
                                                        message:errorString
                                                 preferredStyle:(UIAlertControllerStyleAlert)];
            [alert addAction:okAction];
            break;
        case InputValidationError:
            alert = [UIAlertController alertControllerWithTitle:kError
                                                    message:kInputValidationErrorMessage
                                             preferredStyle:(UIAlertControllerStyleAlert)];
            [alert addAction:okAction];
            break;
    }
    [vc presentViewController:alert animated:YES completion:^{}];
}

+ (void)logoutAlert:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kLogOut
                                                                   message:kLogOutMessage
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kCancel
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kLogOut
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [DatabaseManager logoutUser:vc];
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [vc presentViewController:alert animated:YES completion:nil];
}
+ (void)videoPermissionAlert:(UIViewController *)vc {
    UIAlertController *alert =  [UIAlertController alertControllerWithTitle:kVideoPermissionAlertTitle
                                                                    message:kVideoPermissionAlertMessage
                                                             preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *openSettingsAction = [UIAlertAction actionWithTitle:kOpenSettings
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
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [vc.navigationController popToRootViewControllerAnimated:YES];
    }];
    
  
    alert = [UIAlertController alertControllerWithTitle:kDealsNotFoundAlertTitle
                                                        message:kDealsNotFoundAlertMessage
                                                 preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:okAction];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)cannotOpenLink:(UIViewController *)vc {
    UIAlertController *alert;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [vc.navigationController popToRootViewControllerAnimated:YES];
    }];
    alert = [UIAlertController alertControllerWithTitle:kCannotOpenLinkAlertTitle
                                                message:kCannotOpenLinkAlertMessage
                                         preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:okAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)cannotSaveDeal:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kCannotSaveDealAlertTitle
                                                                   message:kCannotSaveDealOrPostDealAlertMessage
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    [alert addAction:okAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)cannotPostDeal:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kCannotPostDealAlertTitle
                                                                   message:kCannotSaveDealOrPostDealAlertMessage
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    [alert addAction:okAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)postDealAlert:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kCannotPostDealAlertTitle
                                                                   message:kPostDealMissingFields
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    [alert addAction:okAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)invalidUrlAlert:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kCannotPostDealAlertTitle
                                                                   message:kInvalidUrl
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    [alert addAction:okAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)invalidPriceInputAlert:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kCannotPostDealAlertTitle
                                                                   message:kInvalidPriceInputAlert
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    [alert addAction:okAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

@end
