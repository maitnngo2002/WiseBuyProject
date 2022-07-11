//
//  LoginViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "LoginViewController.h"
#import "ALertManager.h"
#import "DatabaseManager.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (IBAction)onSignInTap:(id)sender {
    [self loginUser];
}

- (void)loginUser {
    if ([self inputFieldsAreEmpty]) {
        [AlertManager loginAlert:LoginErrorMissingInput errorString:nil viewController:self];
        return;
    }
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [DatabaseManager loginUser:username password:password withCompletion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
        else {
            [AlertManager loginAlert:ServerError errorString: error.localizedDescription viewController:self];
        }
    }];
}

- (BOOL)inputFieldsAreEmpty {
    return [self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""];
}

@end
